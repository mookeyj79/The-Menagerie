#!/usr/bin/env python3
"""Print the key paths of a YAML or JSON file, never its values.

Use this to look inside secret-bearing files (host_vars, tfvars-style YAML,
JSON dumps) without putting a secret on screen or in a session transcript.

    python Scripts/gate/keys.py <file>...

One line per key path, e.g. `backup.ssh_private_key`; list items show as `[]`.
Only keys are ever written to stdout.
"""
import sys

import yaml


def key_paths(node, prefix=""):
    if isinstance(node, dict):
        for key, value in node.items():
            path = f"{prefix}.{key}" if prefix else str(key)
            yield path
            yield from key_paths(value, path)
    elif isinstance(node, list):
        for item in node:
            yield from key_paths(item, f"{prefix}[]")


def main(paths):
    if not paths:
        print(__doc__.strip().splitlines()[0], file=sys.stderr)
        return 2
    status = 0
    for path in paths:
        try:
            with open(path, encoding="utf-8", newline="") as handle:
                docs = list(yaml.safe_load_all(handle))
        except (OSError, yaml.YAMLError) as exc:
            # Report the exception class only: YAML errors can quote file content.
            print(f"{path}: cannot read ({type(exc).__name__})", file=sys.stderr)
            status = 1
            continue
        print(f"== {path}")
        for doc in docs:
            seen = set()
            for key_path in key_paths(doc):
                if key_path not in seen:
                    seen.add(key_path)
                    print(key_path)
    return status


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
