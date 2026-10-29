#!/usr/bin/env python3
"""
confcrypt v2 - whole-line protection of secrets in unstructured text files
(RouterOS .rsc, Cisco IOS, the Wi-Fi notes file).

A dialect (see .confcrypt.yml) has a comment syntax and a list of rules.
A rule is a line regex plus a fixed dummy line. Encrypting replaces every
matching line, whole, with its dummy and puts the age-encrypted original in
a metadata comment directly above it:

    # confcrypt v2 <urlsafe-base64 age blob>
    /user add name=REDACTED group=REDACTED password=REDACTED

An *Encrypted line* is exactly that pairing (metadata line, then the exact
dummy), so a dummy that happens to match its own regex is never mistaken
for plaintext, and encrypt is idempotent. Decrypting swaps the original
back in and refuses if the line under a metadata line is not the rule's
dummy. Files are read and written as UTF-8 with line endings preserved, so
round trips are byte-exact.

Recipients come from the nearest .sops.yaml (every age recipient in its
creation_rules). The identity (decrypt only) is always a *path*: --identity,
$SOPS_AGE_KEY_FILE, .confcrypt.yml `identity:`, then ~/.sops/keys.txt.
Nothing secret is ever accepted as an argument or printed.

Usage:
    confcrypt.py encrypt <file> [--config P] [--sops-config P] [--dialect D]
                          [--in-place [--backup] | -o OUT]
    confcrypt.py decrypt <file> [--config P] [--dialect D] [--identity P]
                          [--in-place [--backup] | -o OUT]
    confcrypt.py edit <file> [--config P] [--sops-config P] [--dialect D] [--identity P]
    confcrypt.py rekey <file> [--config P] [--sops-config P] [--dialect D] [--identity P]
                          [--in-place [--backup] | -o OUT]
    confcrypt.py encrypt <file> --dry-run   (reports file:line and rule only)
"""
import argparse
import base64
import fnmatch
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile

import pyrage
import yaml

DEFAULT_IDENTITY = "~/.sops/keys.txt"
META_TAG = "confcrypt v2"


class ConfcryptError(Exception):
    """A user-facing error. Messages never contain protected values."""


# ---------------------------------------------------------------- helpers --

def b64e(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def b64d(s: str) -> bytes:
    return base64.urlsafe_b64decode(s + "=" * (-len(s) % 4))


def split_lines(text):
    """Split into (body, eol) pairs on \\n / \\r\\n only, losslessly."""
    parts = text.split("\n")
    out = []
    for i, p in enumerate(parts):
        last = i == len(parts) - 1
        if last:
            if p:
                out.append((p, ""))
        elif p.endswith("\r"):
            out.append((p[:-1], "\r\n"))
        else:
            out.append((p, "\n"))
    return out


def read_text(path):
    with open(path, "rb") as f:
        try:
            return f.read().decode("utf-8")
        except UnicodeDecodeError:
            raise ConfcryptError(f"{path} is not valid UTF-8")


def walk_up(start_dir, name):
    d = os.path.abspath(start_dir)
    while True:
        cand = os.path.join(d, name)
        if os.path.isfile(cand):
            return cand
        parent = os.path.dirname(d)
        if parent == d:
            return None
        d = parent


# ---------------------------------------------------------------- config --

class Rule:
    def __init__(self, regex, dummy):
        self.regex = regex
        self.dummy = dummy

    def matches(self, body):
        return self.regex.search(body) is not None


class Dialect:
    def __init__(self, name, comment, rules, files, tripwire):
        self.name = name
        self.comment = comment
        self.rules = rules
        self.files = files
        self.tripwire = tripwire
        self.meta_re = re.compile(
            "^" + re.escape(comment) + " " + re.escape(META_TAG) + r" (\S+)$"
        )

    def rule_for(self, body):
        for r in self.rules:
            if r.matches(body):
                return r
        return None

    def is_dummy(self, body):
        return any(body == r.dummy for r in self.rules)


def load_config(path):
    with open(path, "rb") as f:
        cfg = yaml.safe_load(f.read().decode("utf-8")) or {}
    dialects = {}
    for name, ft in (cfg.get("filetypes") or {}).items():
        where = f"{path}: filetypes.{name}"
        if not isinstance(ft, dict) or not ft.get("comment") or not ft.get("rules"):
            raise ConfcryptError(f"{where} needs 'comment' and a non-empty 'rules' list")
        rules = []
        for i, r in enumerate(ft["rules"]):
            try:
                rx = re.compile(r["regex"])
                dummy = r["dummy"]
            except (KeyError, TypeError, re.error) as e:
                raise ConfcryptError(f"{where}.rules[{i}]: needs a valid 'regex' and 'dummy' ({e})")
            if not isinstance(dummy, str) or "\n" in dummy or "\r" in dummy or not dummy:
                raise ConfcryptError(f"{where}.rules[{i}]: dummy must be a non-empty single line")
            if not rx.search(dummy):
                raise ConfcryptError(
                    f"{where}.rules[{i}]: dummy does not match its own regex"
                )
            rules.append(Rule(rx, dummy))
        tripwire = None
        if ft.get("tripwire"):
            try:
                tripwire = re.compile(ft["tripwire"])
            except re.error as e:
                raise ConfcryptError(f"{where}.tripwire: invalid regex ({e})")
        dialects[name] = Dialect(name, ft["comment"], rules, ft.get("files") or [], tripwire)
    return cfg, dialects


def find_config(cli_path, target):
    if cli_path:
        if not os.path.isfile(cli_path):
            raise ConfcryptError(f"--config file not found: {cli_path}")
        return cli_path
    found = walk_up(os.path.dirname(os.path.abspath(target)), ".confcrypt.yml")
    if found:
        return found
    home = os.path.expanduser("~/.confcrypt.yml")
    if os.path.isfile(home):
        return home
    raise ConfcryptError("No .confcrypt.yml found above the target file or at ~/.confcrypt.yml")


def pick_dialect(target, cli_dialect, dialects, config_path):
    if cli_dialect:
        if cli_dialect not in dialects:
            raise ConfcryptError(f"No dialect '{cli_dialect}' in {config_path}")
        return dialects[cli_dialect]
    rel = os.path.relpath(os.path.abspath(target), os.path.dirname(os.path.abspath(config_path)))
    rel = rel.replace(os.sep, "/")
    for d in dialects.values():
        if any(fnmatch.fnmatchcase(rel, g) for g in d.files):
            return d
    ext = os.path.splitext(target)[1].lstrip(".").lower()
    if ext in dialects:
        return dialects[ext]
    raise ConfcryptError(
        f"No dialect for {os.path.basename(target)} (known: {', '.join(sorted(dialects))}); use --dialect"
    )


# ------------------------------------------------------------------ keys --

def load_recipients(cli_sops, target):
    path = cli_sops or walk_up(os.path.dirname(os.path.abspath(target)), ".sops.yaml")
    if not path or not os.path.isfile(path):
        raise ConfcryptError("No .sops.yaml found above the target file (recipients come from it)")
    with open(path, "rb") as f:
        doc = yaml.safe_load(f.read().decode("utf-8")) or {}
    keys = []

    def add(value):
        if isinstance(value, str):
            keys.extend(k.strip() for k in value.split(",") if k.strip())
        elif isinstance(value, list):
            for v in value:
                add(v)

    for rule in doc.get("creation_rules") or []:
        add(rule.get("age"))
        for group in rule.get("key_groups") or []:
            add(group.get("age"))
    recipients, seen = [], set()
    for k in keys:
        if k in seen:
            continue
        seen.add(k)
        try:
            recipients.append(pyrage.x25519.Recipient.from_str(k))
        except Exception:
            raise ConfcryptError(f"{path}: invalid age recipient '{k[:12]}...'")
    if not recipients:
        raise ConfcryptError(f"{path} lists no age recipients")
    return recipients


def load_identities(cli_identity, cfg):
    path = (
        cli_identity
        or os.environ.get("SOPS_AGE_KEY_FILE")
        or cfg.get("identity")
        or DEFAULT_IDENTITY
    )
    path = os.path.expanduser(path)
    if not os.path.isfile(path):
        raise ConfcryptError(f"Identity file not found: {path}")
    ids = []
    with open(path, "rb") as f:
        for line in f.read().decode("utf-8").splitlines():
            line = line.strip()
            if line and not line.startswith("#"):
                try:
                    ids.append(pyrage.x25519.Identity.from_str(line))
                except Exception:
                    raise ConfcryptError(f"Unreadable age identity line in {path}")
    if not ids:
        raise ConfcryptError(f"No AGE-SECRET-KEY lines in {path}")
    return ids


# ------------------------------------------------------------------ core --

def encrypt_text(text, dialect, recipients, reuse=None):
    """Return (new_text, protected_count)."""
    lines = split_lines(text)
    default_eol = next((e for _, e in lines if e), "\n")
    out, count, i = [], 0, 0
    while i < len(lines):
        body, eol = lines[i]
        m = dialect.meta_re.match(body)
        if m:
            if i + 1 >= len(lines):
                raise ConfcryptError(f"line {i + 1}: metadata line at end of file")
            nbody, _ = lines[i + 1]
            if not dialect.is_dummy(nbody):
                raise ConfcryptError(f"line {i + 2}: line under metadata is not a rule dummy")
            out.append(body + eol)
            out.append(lines[i + 1][0] + lines[i + 1][1])
            i += 2
            continue
        rule = dialect.rule_for(body)
        if rule is None:
            out.append(body + eol)
        else:
            # reuse: {original line: [blob, ...]} from `edit`, so unchanged lines
            # keep their blob (consumed once per occurrence) and diffs stay quiet.
            old = (reuse or {}).get(body)
            blob = old.pop(0) if old else b64e(pyrage.encrypt(body.encode("utf-8"), recipients))
            out.append(f"{dialect.comment} {META_TAG} {blob}{eol or default_eol}")
            out.append(rule.dummy + eol)
            count += 1
        i += 1
    return "".join(out), count


def decrypt_text(text, dialect, identities):
    """Return (new_text, restored_count)."""
    lines = split_lines(text)
    out, count, i = [], 0, 0
    while i < len(lines):
        body, eol = lines[i]
        m = dialect.meta_re.match(body)
        if not m:
            out.append(body + eol)
            i += 1
            continue
        if i + 1 >= len(lines):
            raise ConfcryptError(f"line {i + 1}: metadata line at end of file")
        try:
            original = pyrage.decrypt(b64d(m.group(1)), identities).decode("utf-8")
        except Exception:
            raise ConfcryptError(f"line {i + 1}: cannot decrypt metadata line (wrong key or corrupt blob)")
        dbody, deol = lines[i + 1]
        rule = dialect.rule_for(original)
        ok = dbody == rule.dummy if rule else dialect.is_dummy(dbody)
        if not ok:
            raise ConfcryptError(
                f"line {i + 2}: line under metadata is not the rule dummy (file was edited by hand?)"
            )
        out.append(original + deol)
        count += 1
        i += 2
    return "".join(out), count


# -------------------------------------------------------------- commands --

def existing_blobs(text, dialect, identities):
    """Map each decrypted original line to its blobs, in file order."""
    found = {}
    for body, _ in split_lines(text):
        m = dialect.meta_re.match(body)
        if m:
            try:
                original = pyrage.decrypt(b64d(m.group(1)), identities).decode("utf-8")
            except Exception:
                continue  # decrypt_text reports undecryptable blobs
            found.setdefault(original, []).append(m.group(1))
    return found


def write_output(text, args):
    data = text.encode("utf-8")
    if args.in_place:
        if args.backup:
            shutil.copy2(args.file, args.file + ".bak")
        with open(args.file, "wb") as f:
            f.write(data)
    elif args.output:
        with open(args.output, "wb") as f:
            f.write(data)
    else:
        sys.stdout.buffer.write(data)
        sys.stdout.buffer.flush()


def prepare(args):
    config_path = find_config(args.config, args.file)
    cfg, dialects = load_config(config_path)
    dialect = pick_dialect(args.file, args.dialect, dialects, config_path)
    return cfg, dialect


def dry_run_report(text, dialect, path):
    """Yield 'file:line: rule N (regex)' for each line encrypt would protect.
    Never includes line content."""
    lines = split_lines(text)
    i = 0
    while i < len(lines):
        body, _ = lines[i]
        if dialect.meta_re.match(body):
            i += 2
            continue
        rule = dialect.rule_for(body)
        if rule is not None:
            n = dialect.rules.index(rule) + 1
            yield f"{path}:{i + 1}: rule {n} ({rule.regex.pattern})"
        i += 1


def cmd_encrypt(args):
    cfg, dialect = prepare(args)
    if args.dry_run:
        found = list(dry_run_report(read_text(args.file), dialect, args.file))
        for line in found:
            print(line)
        print(f"Would protect {len(found)} line(s).", file=sys.stderr)
        return
    recipients = load_recipients(args.sops_config, args.file)
    text, count = encrypt_text(read_text(args.file), dialect, recipients)
    write_output(text, args)
    print(f"Protected {count} line(s).", file=sys.stderr)


def cmd_decrypt(args):
    cfg, dialect = prepare(args)
    identities = load_identities(args.identity, cfg)
    text, count = decrypt_text(read_text(args.file), dialect, identities)
    write_output(text, args)
    print(f"Restored {count} line(s).", file=sys.stderr)


# ------------------------------------------------------------ edit command --

def run_editor(path):
    editor = os.environ.get("VISUAL") or os.environ.get("EDITOR")
    if not editor:
        raise ConfcryptError("Set $EDITOR (or $VISUAL) to use edit")
    cmd = shlex.split(editor, posix=True) + [path]
    try:
        rc = subprocess.call(cmd)
    except OSError as e:
        raise ConfcryptError(f"cannot run editor: {e.strerror or e}")
    if rc != 0:
        raise ConfcryptError(f"editor exited with status {rc}; file left unchanged")


def cmd_edit(args):
    cfg, dialect = prepare(args)
    recipients = load_recipients(args.sops_config, args.file)
    identities = load_identities(args.identity, cfg)
    original = read_text(args.file)
    plain, _ = decrypt_text(original, dialect, identities)
    reuse = existing_blobs(original, dialect, identities)
    suffix = os.path.splitext(args.file)[1]
    fd, tmp = tempfile.mkstemp(prefix="confcrypt-", suffix=suffix)  # created 0600
    try:
        try:
            os.chmod(tmp, 0o600)
        except OSError:
            pass
        with os.fdopen(fd, "wb") as f:
            f.write(plain.encode("utf-8"))
        run_editor(tmp)
        edited = read_text(tmp)
    finally:
        try:
            os.remove(tmp)
        except FileNotFoundError:
            pass
    if edited == plain:
        print("No changes.", file=sys.stderr)
        return
    text, count = encrypt_text(edited, dialect, recipients, reuse=reuse)
    with open(args.file, "wb") as f:
        f.write(text.encode("utf-8"))
    print(f"Saved; {count} protected line(s).", file=sys.stderr)


# ---------------------------------------------------------- rekey command --

def cmd_rekey(args):
    """Decrypt every blob and re-encrypt to the current .sops.yaml recipients.
    The only operation that rewrites every blob."""
    cfg, dialect = prepare(args)
    recipients = load_recipients(args.sops_config, args.file)
    identities = load_identities(args.identity, cfg)
    plain, _ = decrypt_text(read_text(args.file), dialect, identities)
    text, count = encrypt_text(plain, dialect, recipients)
    write_output(text, args)
    print(f"Rekeyed {count} line(s).", file=sys.stderr)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    def common(p):
        p.add_argument("file")
        p.add_argument("--config", help="path to .confcrypt.yml (default: nearest above the file)")
        p.add_argument("--dialect", help="override dialect selection")
        p.add_argument("--backup", action="store_true", help="with --in-place: keep <file>.bak")
        out = p.add_mutually_exclusive_group()
        out.add_argument("--in-place", action="store_true")
        out.add_argument("-o", "--output")

    p = sub.add_parser("encrypt")
    common(p)
    p.add_argument("--sops-config", help="path to .sops.yaml (default: nearest above the file)")
    p.add_argument("--dry-run", action="store_true",
                   help="report file:line and rule of lines that would be protected; write nothing")
    p.set_defaults(func=cmd_encrypt)

    p = sub.add_parser("decrypt")
    common(p)
    p.add_argument("--identity", help="age identity file path")
    p.set_defaults(func=cmd_decrypt)

    p = sub.add_parser("rekey", help="re-encrypt every blob to the current recipients")
    common(p)
    p.add_argument("--sops-config", help="path to .sops.yaml (default: nearest above the file)")
    p.add_argument("--identity", help="age identity file path")
    p.set_defaults(func=cmd_rekey)

    p = sub.add_parser("edit",help="decrypt to an owner-only temp file, run $EDITOR, re-encrypt in place")
    p.add_argument("file")
    p.add_argument("--config")
    p.add_argument("--dialect")
    p.add_argument("--sops-config")
    p.add_argument("--identity", help="age identity file path")
    p.set_defaults(func=cmd_edit)

    args = ap.parse_args(argv)
    try:
        args.func(args)
    except ConfcryptError as e:
        print(f"confcrypt: error: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
