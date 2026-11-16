#!/usr/bin/env bash
# setup-sandbox.sh - Install what the git hooks (Scripts/gate/gate.sh) and the
# tests need in a Linux x86_64 sandbox, pinned to the versions CI uses.
# Usage: bash Scripts/setup-sandbox.sh
#
# Installs into ~/.cache/menagerie-sandbox (override with MENAGERIE_SANDBOX_DIR):
#   bin/gitleaks, bin/sops   checksum-verified release binaries
#   venv/                    CPython 3.12 (as on the ubuntu-24.04 runner) with
#                            .github/gate-requirements.txt and
#                            .github/test-requirements.txt, hash-checked
# then points core.hooksPath at .githooks and prints the exports the gate reads.
# Safe to re-run. Keep GITLEAKS_* and SOPS_* in step with
# .github/workflows/gate.yml and tests.yml.
set -euo pipefail

GITLEAKS_VERSION=8.30.1
GITLEAKS_SHA256=551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb
SOPS_VERSION=3.13.3
SOPS_SHA256=e5bec3346a873ae91d871550f3e698c1aad962aff462a080e40f25fde17fef6b
PYTHON_VERSION=3.12

root=$(cd "$(dirname "$0")/.." && pwd)
base="${MENAGERIE_SANDBOX_DIR:-$HOME/.cache/menagerie-sandbox}"
bin="$base/bin"
venv="$base/venv"
mkdir -p "$bin"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# gitleaks: the tarball is verified, so check the installed binary by version.
if [ "$("$bin/gitleaks" version 2>/dev/null || true)" != "$GITLEAKS_VERSION" ]; then
    curl -fsSLo "$tmp/gitleaks.tar.gz" \
        "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz"
    echo "$GITLEAKS_SHA256  $tmp/gitleaks.tar.gz" | sha256sum -c --quiet -
    tar -xzf "$tmp/gitleaks.tar.gz" -C "$tmp" gitleaks
    install -m 0755 "$tmp/gitleaks" "$bin/gitleaks"
fi
echo "gitleaks $("$bin/gitleaks" version) ready"

# sops: the release asset is the binary itself, so its checksum is checked in place.
if ! echo "$SOPS_SHA256  $bin/sops" | sha256sum -c --quiet - >/dev/null 2>&1; then
    curl -fsSLo "$tmp/sops" \
        "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64"
    echo "$SOPS_SHA256  $tmp/sops" | sha256sum -c --quiet -
    install -m 0755 "$tmp/sops" "$bin/sops"
fi
echo "sops $SOPS_VERSION ready"

# Python venv: the requirement hashes are for CPython 3.12 wheels, so other
# versions fail the hash check. uv fetches a managed 3.12 when none is installed.
if ! "$venv/bin/python" -c "import sys; sys.exit(sys.version_info[:2] != tuple(map(int, '$PYTHON_VERSION'.split('.'))))" 2>/dev/null; then
    rm -rf "$venv"
    uv venv --quiet --python "$PYTHON_VERSION" "$venv"
fi
uv pip install --quiet --python "$venv/bin/python" --require-hashes --only-binary :all: \
    -r "$root/.github/gate-requirements.txt" -r "$root/.github/test-requirements.txt"
"$venv/bin/python" -c 'import yaml, pyrage, pytest, sys; print("python %d.%d.%d ready (pyyaml, pyrage, pytest)" % sys.version_info[:3])'

sh "$root/Scripts/install-hooks.sh"

cat <<EOF

Export these before committing (gate.sh reads GATE_*; PATH gives python and pytest):
  export GATE_GITLEAKS="$bin/gitleaks"
  export GATE_SOPS="$bin/sops"
  export GATE_PYTHON="$venv/bin/python"
  export PATH="$bin:$venv/bin:\$PATH"
sandbox ready
EOF
