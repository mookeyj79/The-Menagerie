#!/usr/bin/env python3
"""
ios_config_diff.py

Compares two Cisco IOS-style config files and prints the CLI commands
needed to turn "original" into "updated" - ready to paste into the
device's global config mode.

Usage:
    python3 ios_config_diff.py original.ios updated.ios

No third-party packages required (standard library only).

How it works
------------
IOS configs are hierarchical: a line like "interface X" is followed by
more-indented sub-commands that belong to it, until indentation drops
back down. This script parses both files into that hierarchy (based on
indentation, not on exact spacing, so it doesn't matter if your export
uses one space or several) and then walks both trees together:

  - a line only in "updated"      -> print it (and, if it's a block
                                      header like "interface X", print
                                      its whole sub-tree too)
  - a line only in "original"     -> print "no <line>"
  - a line in both                -> print nothing for the line itself,
                                      but still walk into its children
                                      in case something below it changed
  - a "no" line has to be printed at zero indentation to actually undo something on the device,
    so if a parent context needed *any* change below it, its header
    line is re-printed once to re-enter that context before the
    changes are listed.

A short list of commands is treated as "overwrite" rather than
"remove + add" (see OVERWRITE_PREFIXES below) - things like hostname,
description, or an interface's ip address, where re-issuing the new
line replaces the old one directly and Cisco IOS doesn't accept
"no <command> <old-value>" as valid syntax. Extend that list for your
own environment if you hit a command that should behave the same way.
"""

import sys

# Commands matched by prefix (not full line) so that an old value and
# a new value are recognized as "the same setting, changed" rather
# than an unrelated removal + addition. For these, only the new line
# is printed - no "no <old line>" is generated.
OVERWRITE_PREFIXES = [
    "hostname",
    "ip domain-name",
    "ip domain name",
    "enable secret",
    "enable password",
    "description",
    "ip address",
    "encapsulation",
    "banner motd",
    "service password-encryption",
    "router-id",
    "switchport access vlan",
    "switchport trunk native vlan",
    "speed",
    "duplex",
]


def is_overwrite_command(line):
    return any(line == p or line.startswith(p + " ") for p in OVERWRITE_PREFIXES)


def prefix_of(line):
    for p in OVERWRITE_PREFIXES:
        if line == p or line.startswith(p + " "):
            return p
    return line


def parse_config(text):
    """Parse config text into a nested dict keyed by stripped command
    text, based on indentation. Returns the top-level dict."""
    root = {}
    stack = [(-1, root)]  # (indent_level, dict_at_that_level)

    for raw in text.splitlines():
        stripped = raw.strip()
        if not stripped or stripped.startswith("!"):
            continue

        indent = len(raw) - len(raw.lstrip(" "))

        while len(stack) > 1 and indent <= stack[-1][0]:
            stack.pop()

        parent = stack[-1][1]
        if stripped not in parent:
            parent[stripped] = {}

        stack.append((indent, parent[stripped]))

    return root


def emit_subtree(tree, depth, out):
    pad = "  " * depth
    for line, children in tree.items():
        out.append(f"{pad}{line}")
        emit_subtree(children, depth + 1, out)


def diff_children(orig, new, depth, out):
    """Diff two dicts of sibling commands, appending needed commands
    to `out`. Returns True if anything changed at this level or below."""
    orig_keys = list(orig.keys())
    new_keys = list(new.keys())
    new_key_set = set(new_keys)
    orig_key_set = set(orig_keys)

    exact_matches = [k for k in orig_keys if k in new_key_set]
    remaining_orig = [k for k in orig_keys if k not in new_key_set]
    remaining_new = [k for k in new_keys if k not in orig_key_set]

    # Pair up overwrite-style commands among what's left (e.g. an old
    # "description OLD" with a new "description NEW").
    by_prefix = {}
    for k in remaining_orig:
        if is_overwrite_command(k):
            by_prefix.setdefault(prefix_of(k), []).append(k)

    pairs = []
    overwrite_old, overwrite_new = set(), set()
    for k in remaining_new:
        if not is_overwrite_command(k):
            continue
        bucket = by_prefix.get(prefix_of(k))
        if bucket:
            old = bucket.pop(0)
            pairs.append((old, k))
            overwrite_old.add(old)
            overwrite_new.add(k)

    removed = [k for k in remaining_orig if k not in overwrite_old]
    added = [k for k in remaining_new if k not in overwrite_new]

    changed = False
    pad = "  " * depth

    for k in removed:
        out.append(f"{pad}no {k}")
        changed = True

    for _old, new_line in pairs:
        out.append(f"{pad}{new_line}")
        changed = True

    for k in added:
        out.append(f"{pad}{k}")
        emit_subtree(new[k], depth + 1, out)
        changed = True

    for k in exact_matches:
        nested = []
        if diff_children(orig[k], new[k], depth + 1, nested):
            out.append(f"{pad}{k}")
            out.extend(nested)
            changed = True

    return changed


def main():
    if len(sys.argv) != 3:
        print("Usage: python3 ios_config_diff.py original.ios updated.ios")
        sys.exit(1)

    orig_path, new_path = sys.argv[1], sys.argv[2]

    with open(orig_path, "r", encoding="utf-8", errors="replace") as f:
        orig_tree = parse_config(f.read())
    with open(new_path, "r", encoding="utf-8", errors="replace") as f:
        new_tree = parse_config(f.read())

    out = []
    changed = diff_children(orig_tree, new_tree, 0, out)

    if not changed:
        print("! No differences found.")
        return

    print(f"! Commands to go from {orig_path} to {new_path}")
    print("configure terminal")
    print("\n".join(out))
    print("end")


if __name__ == "__main__":
    main()
