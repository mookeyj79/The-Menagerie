#!/usr/bin/env python3
"""
confcrypt.py — selective encryption of sensitive values inside unstructured
config files (RouterOS .rsc, Cisco IOS, or anything else a regex can
describe), driven by a dotfile config instead of flags.

Design:
  - A dotfile (.confcrypt.yml) maps file extension -> "dialect": the
    dialect's comment character, and a list of {placeholder, regex}
    patterns describing which values to protect. Resolved the way SOPS
    resolves .sops.yaml: starting from the directory containing the
    target FILE (not cwd), walk up toward the filesystem root using the
    first .confcrypt.yml found; ~/.confcrypt.yml is a last-resort
    fallback. --config always wins outright.
  - Encrypting a line replaces the matched value with a readable
    <PLACEHOLDER> token in place, and inserts one native-comment line
    directly above it per secret, carrying the ciphertext:

        # confcrypt PASSWORD ageenc_AbC123...
        /user add name="<USER>" password="<PASSWORD>"

    Because the metadata lives in the file's own comment syntax, an
    un-decrypted file stays syntactically inert to the device that would
    otherwise parse it (RouterOS ignores `#` lines; Cisco IOS ignores `!`
    lines) instead of embedding an opaque blob mid-line.
  - Decrypting is symmetric: it reads dialect from the same config, finds
    `confcrypt` comment lines, decrypts them, substitutes the token(s) on
    the following line, and drops the comment lines — restoring the file
    byte-for-byte to what it was before encryption.
  - No private key material, passphrase, or password is ever accepted as
    a CLI argument. The identity is always a *path* to a key file (same
    convention SOPS uses), resolved from --identity, then
    $SOPS_AGE_KEY_FILE, then .confcrypt.yml's `identity:`, then
    ~/.sops/keys.txt.

Usage:
    confcrypt.py encrypt <file> [--config PATH] [--dialect X] [--identity PATH]
                          [--recipient age1...]... [--in-place | -o OUT] [--backup]
    confcrypt.py decrypt <file> [--config PATH] [--dialect X] [--identity PATH]
                          [--in-place | -o OUT] [--backup]
    confcrypt.py edit    <file> [--config PATH] [--dialect X] [--identity PATH]
                          [--editor CMD] [--backup]
"""
import argparse
import base64
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile

import yaml
import pyrage

DEFAULT_IDENTITY = "~/.sops/keys.txt"
META_PREFIX = "confcrypt"
MAX_MATCHES_PER_PATTERN_PER_LINE = 20  # safety valve, not a real limit


def b64e(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def b64d(s: str) -> bytes:
    pad = "=" * (-len(s) % 4)
    return base64.urlsafe_b64decode(s + pad)


# ---------------------------------------------------------------- config --

def find_config(cli_path, target_file):
    """Resolve .confcrypt.yml the way SOPS resolves .sops.yaml: starting
    from the directory that CONTAINS the target file (not cwd), walk up
    toward the filesystem root, using the first .confcrypt.yml found.
    Falls back to ~/.confcrypt.yml only if nothing turns up in the tree.
    """
    if cli_path:
        if not os.path.isfile(cli_path):
            sys.exit(f"--config file not found: {cli_path}")
        return cli_path

    start_dir = os.path.dirname(os.path.abspath(target_file))
    d = start_dir
    while True:
        candidate = os.path.join(d, ".confcrypt.yml")
        if os.path.isfile(candidate):
            return candidate
        parent = os.path.dirname(d)
        if parent == d:  # reached filesystem root
            break
        d = parent

    home_candidate = os.path.expanduser("~/.confcrypt.yml")
    if os.path.isfile(home_candidate):
        return home_candidate

    sys.exit(
        f"No .confcrypt.yml found walking up from {start_dir}, and none at "
        "~/.confcrypt.yml. Pass --config explicitly or create one — see "
        ".confcrypt.yml.example."
    )


def load_config(path):
    with open(path) as f:
        cfg = yaml.safe_load(f) or {}
    cfg.setdefault("filetypes", {})
    cfg.setdefault("recipients", [])
    return cfg


def resolve_dialect(file_path, cli_dialect, config, config_path):
    dialect = cli_dialect or os.path.splitext(file_path)[1].lstrip(".").lower()
    if not dialect:
        sys.exit("Could not infer dialect from file extension; pass --dialect explicitly.")
    ft = config["filetypes"].get(dialect)
    if not ft:
        known = ", ".join(sorted(config["filetypes"])) or "(none defined)"
        sys.exit(f"No filetype '{dialect}' in {config_path}. Known filetypes: {known}")
    if "comment" not in ft or "patterns" not in ft:
        sys.exit(f"filetypes.{dialect} in {config_path} needs both 'comment' and 'patterns'")
    patterns = []
    for p in ft["patterns"]:
        rx = re.compile(p["regex"])
        if rx.groups != 1:
            sys.exit(f"Pattern for placeholder '{p['placeholder']}' must have exactly 1 capture group")
        patterns.append((p["placeholder"], rx))
    return dialect, ft["comment"], patterns


def resolve_identity_path(cli_identity, config):
    return (
        cli_identity
        or os.environ.get("SOPS_AGE_KEY_FILE")
        or config.get("identity")
        or DEFAULT_IDENTITY
    )


def load_identities(path):
    path = os.path.expanduser(path)
    if not os.path.isfile(path):
        sys.exit(f"Identity file not found: {path}")
    lines = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#"):
                lines.append(line)
    if not lines:
        sys.exit(f"No AGE-SECRET-KEY lines found in {path}")
    return [pyrage.x25519.Identity.from_str(l) for l in lines]


def resolve_recipients(config, identities, cli_recipients):
    recipients = [i.to_public() for i in identities]
    for r in config.get("recipients") or []:
        recipients.append(pyrage.x25519.Recipient.from_str(r))
    for r in cli_recipients or []:
        recipients.append(pyrage.x25519.Recipient.from_str(r))
    # dedupe by string form, preserve order
    seen, unique = set(), []
    for r in recipients:
        s = str(r)
        if s not in seen:
            seen.add(s)
            unique.append(r)
    return unique


# --------------------------------------------------------------- core io --

def split_eol(line):
    for eol in ("\r\n", "\n"):
        if line.endswith(eol):
            return line[: -len(eol)], eol
    return line, ""


def redact_line(line, patterns, recipients):
    """Return (possibly modified line, [(placeholder, ciphertext_b64), ...])."""
    body, eol = split_eol(line)
    secrets = []
    for placeholder, rx in patterns:
        token = f"<{placeholder}>"
        guard = 0
        while True:
            guard += 1
            if guard > MAX_MATCHES_PER_PATTERN_PER_LINE:
                break
            m = rx.search(body)
            if not m:
                break
            val = m.group(1)
            if val == token or val == placeholder:
                break  # already redacted — idempotent no-op for this pattern
            ct = pyrage.encrypt(val.encode(), recipients)
            secrets.append((placeholder, b64e(ct)))
            body = body[: m.start(1)] + token + body[m.end(1):]
    return body + eol, secrets


def encrypt_text(text, comment, patterns, recipients):
    out = []
    total = 0
    for line in text.splitlines(keepends=True):
        new_line, secrets = redact_line(line, patterns, recipients)
        if secrets:
            _, eol = split_eol(new_line)
            for placeholder, blob in secrets:
                out.append(f"{comment} {META_PREFIX} {placeholder} {blob}{eol}")
                total += 1
        out.append(new_line)
    return "".join(out), total


def decrypt_text(text, comment, identities):
    meta_re = re.compile(rf"^{re.escape(comment)}\s*{META_PREFIX}\s+(\S+)\s+(\S+)\s*$")
    out = []
    pending = []
    count = 0
    for line in text.splitlines(keepends=True):
        body, _ = split_eol(line)
        m = meta_re.match(body)
        if m:
            placeholder, blob = m.group(1), m.group(2)
            pt = pyrage.decrypt(b64d(blob), identities).decode()
            pending.append((placeholder, pt))
            continue
        new_line = line
        for placeholder, pt in pending:
            new_line = new_line.replace(f"<{placeholder}>", pt, 1)
            count += 1
        pending = []
        out.append(new_line)
    if pending:
        print(
            f"Warning: {len(pending)} confcrypt metadata line(s) at EOF had no line to apply to",
            file=sys.stderr,
        )
    return "".join(out), count


# ---------------------------------------------------------------- output --

def write_output(text, args, src_path):
    if args.in_place:
        if args.backup:
            shutil.copy2(src_path, src_path + ".bak")
            print(f"Backed up to {src_path}.bak", file=sys.stderr)
        with open(src_path, "w", newline="") as f:
            f.write(text)
        print(f"Wrote {src_path}", file=sys.stderr)
    elif args.output:
        with open(args.output, "w", newline="") as f:
            f.write(text)
        print(f"Wrote {args.output}", file=sys.stderr)
    else:
        sys.stdout.write(text)


# --------------------------------------------------------------- commands --

def cmd_encrypt(args):
    config_path = find_config(args.config, args.file)
    config = load_config(config_path)
    _, comment, patterns = resolve_dialect(args.file, args.dialect, config, config_path)

    identity_path = resolve_identity_path(args.identity, config)
    identities = load_identities(identity_path)
    recipients = resolve_recipients(config, identities, args.recipient)

    with open(args.file) as f:
        text = f.read()
    text, total = encrypt_text(text, comment, patterns, recipients)
    if total == 0:
        print("No new values encrypted (already encrypted, or no pattern matched).", file=sys.stderr)
    else:
        print(f"Encrypted {total} value(s).", file=sys.stderr)
    write_output(text, args, args.file)


def cmd_decrypt(args):
    config_path = find_config(args.config, args.file)
    config = load_config(config_path)
    _, comment, _patterns = resolve_dialect(args.file, args.dialect, config, config_path)

    identity_path = resolve_identity_path(args.identity, config)
    identities = load_identities(identity_path)

    with open(args.file) as f:
        text = f.read()
    text, count = decrypt_text(text, comment, identities)
    print(f"Decrypted {count} value(s).", file=sys.stderr)
    write_output(text, args, args.file)


def cmd_edit(args):
    config_path = find_config(args.config, args.file)
    config = load_config(config_path)
    _, comment, patterns = resolve_dialect(args.file, args.dialect, config, config_path)

    identity_path = resolve_identity_path(args.identity, config)
    identities = load_identities(identity_path)
    recipients = resolve_recipients(config, identities, [])

    with open(args.file) as f:
        original = f.read()
    decrypted, _ = decrypt_text(original, comment, identities)

    suffix = os.path.splitext(args.file)[1] or ".txt"
    with tempfile.NamedTemporaryFile(mode="w", suffix=suffix, delete=False, newline="") as tf:
        tf.write(decrypted)
        tmp_path = tf.name

    editor = args.editor or os.environ.get("EDITOR") or ("notepad" if os.name == "nt" else "vi")
    try:
        subprocess.run([*shlex.split(editor), tmp_path], check=True)
        with open(tmp_path) as f:
            edited = f.read()

        reencrypted, _ = encrypt_text(edited, comment, patterns, recipients)
        if reencrypted == original:
            print("No changes.", file=sys.stderr)
            return
        if args.backup:
            shutil.copy2(args.file, args.file + ".bak")
            print(f"Backed up to {args.file}.bak", file=sys.stderr)
        with open(args.file, "w", newline="") as f:
            f.write(reencrypted)
        print(f"Wrote {args.file}", file=sys.stderr)
    finally:
        os.unlink(tmp_path)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    def add_common(p):
        p.add_argument("file")
        p.add_argument("--config", help="path to .confcrypt.yml (default: ./.confcrypt.yml, then ~/.confcrypt.yml)")
        p.add_argument("--dialect", help="override filetype key (default: derived from file extension)")
        p.add_argument("--identity", help=f"age identity file (default: $SOPS_AGE_KEY_FILE, then config, then {DEFAULT_IDENTITY})")
        p.add_argument("--backup", action="store_true", help="copy the original to <file>.bak before writing in-place")
        out = p.add_mutually_exclusive_group()
        out.add_argument("--in-place", action="store_true")
        out.add_argument("-o", "--output")

    p_enc = sub.add_parser("encrypt")
    add_common(p_enc)
    p_enc.add_argument("--recipient", action="append", help="extra age1... recipient (repeatable)")
    p_enc.set_defaults(func=cmd_encrypt)

    p_dec = sub.add_parser("decrypt")
    add_common(p_dec)
    p_dec.set_defaults(func=cmd_decrypt)

    p_edit = sub.add_parser("edit")
    add_common(p_edit)
    p_edit.add_argument("--editor", help="override $EDITOR")
    p_edit.set_defaults(func=cmd_edit)

    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
