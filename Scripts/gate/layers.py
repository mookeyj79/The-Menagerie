#!/usr/bin/env python3
"""Helpers for gate.sh. Output is layer, rule, file and line only; never a value.

    layers.py gitleaks-report <label> <report.json>
    layers.py confcrypt <tree> <list>   confcrypt check over managed files
    layers.py sops <tree> <list>        SOPS metadata check over governed files
    layers.py review <tree> <list>      identifying details for manual review (never fails)
    layers.py copy-files <src> <dst> <list>  copy listed files from src to dst

<tree> is a materialized copy of the index; <list> holds NUL-separated paths
relative to it (the files to check). Exit 1 on any finding.
"""
import json
import os
import re
import shutil
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "confcrypt"))


def read_list(path):
    with open(path, "rb") as f:
        return [p.decode("utf-8") for p in f.read().split(b"\0") if p]


def copy_files(src, dst, rels):
    """Copy each listed file from src to the same relative path under dst."""
    for rel in rels:
        target = os.path.join(dst, rel)
        os.makedirs(os.path.dirname(target), exist_ok=True)
        shutil.copyfile(os.path.join(src, rel), target)
    return 0


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


# ---- identifying-details review (reported, never failing) -----------------

REVIEW_CONFIG = os.path.join(HERE, "review.yml")
EMAIL_RX = re.compile(r"[A-Za-z0-9._%+-]+@([A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+)")
IP_RX = re.compile(r"(?<![\d.])(?:\d{1,3}\.){3}\d{1,3}(?!\d|\.\d)")
MAC_RX = re.compile(
    r"(?<![0-9A-Fa-f:.-])(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}(?![0-9A-Fa-f:-])"
    r"|(?<![0-9A-Fa-f.])[0-9A-Fa-f]{4}\.[0-9A-Fa-f]{4}\.[0-9A-Fa-f]{4}(?![0-9A-Fa-f.])"
)


def _review_config(path=REVIEW_CONFIG):
    """(lab_domain, resolvers) from review.yml; this lab's values live there."""
    import yaml

    try:
        with open(path, encoding="utf-8") as f:
            cfg = yaml.safe_load(f) or {}
    except FileNotFoundError:
        cfg = {}
    domain = str(cfg.get("lab_domain") or "").lower().lstrip(".")
    return domain, {str(r) for r in cfg.get("resolvers") or []}


def _internal_email_domain(domain, lab):
    domain = domain.lower()
    return bool(lab) and (domain == lab or domain.endswith("." + lab))


def _line_kinds(line, lab_domain, resolvers):
    """Kinds of identifying detail on one line (values are never returned)."""
    import ipaddress

    kinds = []
    if any(not _internal_email_domain(m.group(1), lab_domain) for m in EMAIL_RX.finditer(line)):
        kinds.append("email")
    for m in IP_RX.finditer(line):
        try:
            ip = ipaddress.IPv4Address(m.group(0))
        except ValueError:
            continue
        if ip.is_global and m.group(0) not in resolvers:
            kinds.append("public-ip")
            break
    # the all-zero MAC is the placeholder confcrypt dummies use, not a device
    if any(set(re.sub(r"[:.-]", "", m.group(0))) != {"0"} for m in MAC_RX.finditer(line)):
        kinds.append("mac")
    return kinds


def review_layer(tree, rels):
    import confcrypt as cc

    rules = _sops_rules(tree)
    lab_domain, resolvers = _review_config()
    for rel in rels:
        if _governing_rule(rules, rel) is not None:
            continue  # SOPS-governed: encrypted path
        full = os.path.join(tree, rel)
        cfg = _find_config(tree, rel)
        if cfg is not None:
            try:
                cc.pick_dialect(full, None, cc.load_config(cfg)[1], cfg)
                continue  # confcrypt-managed: encrypted path (the check layer covers it)
            except cc.ConfcryptError:
                pass
        try:
            with open(full, "rb") as f:
                data = f.read()
        except OSError:
            continue
        if b"\0" in data:
            continue
        for n, line in enumerate(data.decode("utf-8", "replace").splitlines(), 1):
            for kind in _line_kinds(line, lab_domain, resolvers):
                print(f"gate: review: {rel}:{n}: {kind} (identifying detail, not blocking)")
    return 0


def main(argv):
    if len(argv) == 4 and argv[1] == "gitleaks-report":
        return gitleaks_report(argv[2], argv[3])
    if len(argv) == 5 and argv[1] == "copy-files":
        return copy_files(argv[2], argv[3], read_list(argv[4]))
    if len(argv) == 4 and argv[1] in ("confcrypt", "sops", "review"):
        fn = {"confcrypt": confcrypt_layer, "sops": sops_layer, "review": review_layer}[argv[1]]
        return fn(argv[2], read_list(argv[3]))
    print(__doc__, file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
