#!/usr/bin/env python3
"""Helpers for gate.sh. Output is layer, rule, file and line only; never a value.

    layers.py gitleaks-report <label> <report.json>
    layers.py confcrypt <tree> <list>   confcrypt check over managed files
    layers.py sops <tree> <list>        SOPS metadata check over governed files

<tree> is a materialized copy of the index; <list> holds NUL-separated paths
relative to it (the files to check). Exit 1 on any finding.
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "confcrypt"))


def read_list(path):
    with open(path, "rb") as f:
        return [p.decode("utf-8") for p in f.read().split(b"\0") if p]


def gitleaks_report(label, path):
    try:
        with open(path, encoding="utf-8") as f:
            findings = json.load(f) or []
    except (OSError, ValueError):
        findings = []
    for f in findings:
        commit = (f.get("Commit") or "")[:8]
        where = f"{f.get('File', '?')}:{f.get('StartLine', '?')}"
        if commit:
            where += f" (commit {commit})"
        print(f"gate: gitleaks[{label}] {f.get('RuleID', '?')}: {where}")
    return 1 if findings else 0


# ---- confcrypt layer ------------------------------------------------------

def _find_config(tree, rel):
    """Nearest .confcrypt.yml above the file, bounded by the tree root."""
    d = os.path.dirname(os.path.join(tree, rel))
    tree = os.path.abspath(tree)
    while True:
        cand = os.path.join(d, ".confcrypt.yml")
        if os.path.isfile(cand):
            return cand
        if os.path.abspath(d) == tree or os.path.dirname(d) == d:
            return None
        d = os.path.dirname(d)


def confcrypt_layer(tree, rels):
    import confcrypt as cc

    failed = False
    cache = {}
    for rel in rels:
        cfg = _find_config(tree, rel)
        if cfg is None:
            continue
        full = os.path.join(tree, rel)
        try:
            if cfg not in cache:
                cache[cfg] = cc.load_config(cfg)[1]
            dialect = cc.pick_dialect(full, None, cache[cfg], cfg)
        except cc.ConfcryptError as e:
            if str(e).startswith("No dialect"):
                continue  # not a confcrypt-managed file
            print(f"gate: confcrypt: {rel}: config error: {e}")
            failed = True
            continue
        try:
            problems = cc.check_text(cc.read_text(full), dialect)
        except cc.ConfcryptError as e:
            print(f"gate: confcrypt: {rel}: {e}")
            failed = True
            continue
        for n, reason in problems:
            print(f"gate: confcrypt: {rel}:{n}: {reason}")
            failed = True
    return 1 if failed else 0


# ---- SOPS layer -----------------------------------------------------------

def _sops_rules(tree):
    import yaml

    path = os.path.join(tree, ".sops.yaml")
    if not os.path.isfile(path):
        return []
    with open(path, encoding="utf-8") as f:
        cfg = yaml.safe_load(f) or {}
    return [r for r in (cfg.get("creation_rules") or []) if r.get("path_regex")]


def _governing_rule(rules, rel):
    forms = (rel.replace("\\", "/"), rel.replace("/", "\\"))
    for r in rules:
        rx = re.compile(r["path_regex"])
        if any(rx.search(p) for p in forms):
            return r
    return None


def _unencrypted_leaves(node):
    if isinstance(node, dict):
        return sum(_unencrypted_leaves(v) for v in node.values())
    if isinstance(node, list):
        return sum(_unencrypted_leaves(v) for v in node)
    return 0 if isinstance(node, str) and node.startswith("ENC[") else 1


def _sops_problem(full, strict, dotenv):
    """Return a reason string, or None when the file is a proper SOPS file."""
    import yaml

    try:
        with open(full, encoding="utf-8") as f:
            text = f.read()
        if dotenv:
            values, mac = [], False
            for line in text.splitlines():
                if not line.strip() or line.lstrip().startswith("#") or "=" not in line:
                    continue
                k, v = line.split("=", 1)
                if k.startswith("sops_"):
                    mac = mac or k == "sops_mac"
                else:
                    values.append(v)
            if not mac:
                return "SOPS-governed file has no SOPS metadata"
            if strict and any(not v.startswith("ENC[") for v in values):
                return "SOPS-governed file has an unencrypted value"
            return None
        doc = yaml.safe_load(text)
    except (OSError, ValueError, yaml.YAMLError):
        return "SOPS-governed file is not parseable"
    meta = doc.get("sops") if isinstance(doc, dict) else None
    if not isinstance(meta, dict) or not meta.get("mac"):
        return "SOPS-governed file has no SOPS metadata"
    if strict:
        body = {k: v for k, v in doc.items() if k != "sops"}
        if _unencrypted_leaves(body):
            return "SOPS-governed file has an unencrypted value"
    return None


def sops_layer(tree, rels):
    rules = _sops_rules(tree)
    failed = False
    for rel in rels:
        if os.path.basename(rel) == ".sops.yaml":
            continue  # the SOPS config itself matches the *.sops.* catch-all
        rule = _governing_rule(rules, rel)
        if rule is None:
            continue
        strict = rule.get("encrypted_regex") in (None, ".*")
        reason = _sops_problem(os.path.join(tree, rel), strict, rel.lower().endswith(".env"))
        if reason:
            print(f"gate: sops: {rel}: {reason}")
            failed = True
    return 1 if failed else 0


def main(argv):
    if len(argv) == 4 and argv[1] == "gitleaks-report":
        return gitleaks_report(argv[2], argv[3])
    if len(argv) == 4 and argv[1] in ("confcrypt", "sops"):
        fn = confcrypt_layer if argv[1] == "confcrypt" else sops_layer
        return fn(argv[2], read_list(argv[3]))
    print(__doc__, file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
