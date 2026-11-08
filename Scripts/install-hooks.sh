#!/bin/sh
# One-time setup: point this clone's core.hooksPath at the tracked .githooks directory.
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
git -C "$root" config core.hooksPath .githooks
chmod +x "$root"/.githooks/* 2>/dev/null || true
echo "install-hooks: core.hooksPath set to .githooks"
