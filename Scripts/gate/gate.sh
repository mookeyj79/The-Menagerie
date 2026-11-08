#!/bin/sh
# Scanning gate. One entry point for the git pre-commit hook and CI.
#
#   gate.sh --staged   scan what is staged (hook)
#   gate.sh --all      scan the full history, the current tree (index plus
#                      uncommitted working-tree changes to tracked files) and
#                      the Ignored set (CI)
#
# Layers (all run, all must pass):
#   a. gitleaks (default rules + custom rules in .gitleaks.toml)
#   b. confcrypt check over confcrypt-managed files
#   c. SOPS metadata check over SOPS-governed files
#   d. --all only: no Ignored-set path may be tracked
#   e. identifying details (emails, public IPs, MACs outside encrypted paths)
#      are reported for manual review and never fail the gate (this lab's
#      domain and expected resolvers: Scripts/gate/review.yml)
#
# Fails closed when gitleaks, sops or python is missing. Override the commands
# with GATE_GITLEAKS, GATE_SOPS and GATE_PYTHON. Findings are reported as
# layer, file and line only; no secret value is ever printed.
set -u

MODE="${1:-}"
case "$MODE" in
  --staged|--all) ;;
  *) echo "usage: gate.sh --staged | --all" >&2; exit 2 ;;
esac

SCRIPT_DIR=$(cd "$(dirname "$0")" && { pwd -W 2>/dev/null || pwd; })
CONFIG="$SCRIPT_DIR/../../.gitleaks.toml"

fail_closed() {
  echo "gate: FAIL (closed): $1" >&2
  exit 2
}

# ---- required tools ------------------------------------------------------
GITLEAKS="${GATE_GITLEAKS:-gitleaks}"
SOPS="${GATE_SOPS:-sops}"
command -v "$GITLEAKS" >/dev/null 2>&1 || fail_closed "gitleaks not found; install it (pinned 8.30.1) and retry"
command -v "$SOPS" >/dev/null 2>&1 || fail_closed "sops not found; install it and retry"

PY=""
if [ -n "${GATE_PYTHON:-}" ]; then
  "$GATE_PYTHON" -c 'import sys' >/dev/null 2>&1 && PY="$GATE_PYTHON"
else
  for c in python3 python; do
    if "$c" -c 'import sys' >/dev/null 2>&1; then PY="$c"; break; fi
  done
fi
[ -n "$PY" ] || fail_closed "python not found (or not runnable); install python with pyyaml and retry"
"$PY" -c 'import yaml' >/dev/null 2>&1 || fail_closed "python lacks the pyyaml module"

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || fail_closed "not inside a git repository"
cd "$ROOT" || fail_closed "cannot enter repository root"

TMP="$(git rev-parse --absolute-git-dir)/gate.$$"
mkdir -p "$TMP" || fail_closed "cannot create scratch directory"
trap 'rm -rf "$TMP"' EXIT INT TERM

STATUS=0
note_fail() { STATUS=1; }

# ---- layer a: gitleaks ---------------------------------------------------
run_gitleaks() { # label, report-name, gitleaks args...
  label=$1; report="$TMP/$2.json"; shift 2
  "$GITLEAKS" "$@" --config "$CONFIG" --no-banner --redact=100 --exit-code 2 \
    --report-format json --report-path "$report" >"$TMP/gl.out" 2>"$TMP/gl.err"
  rc=$?
  if [ "$rc" -ge 3 ] || [ "$rc" -eq 1 ]; then
    echo "gate: gitleaks ($label) failed to run (exit $rc)" >&2
    note_fail
  elif [ "$rc" -eq 2 ]; then
    "$PY" "$SCRIPT_DIR/layers.py" gitleaks-report "$label" "$report" >&2
    note_fail
  fi
}

# gitleaks silently honours a .gitleaksignore at the repo root, but its
# line-number fingerprints go stale. Reviewed exceptions live in .gitleaks.toml
# (commented path entry) or inline `gitleaks:allow` only, so the file is refused.
if [ -e "$ROOT/.gitleaksignore" ]; then
  echo "gate: .gitleaksignore is not allowed: record reviewed false positives in .gitleaks.toml or with an inline gitleaks:allow" >&2
  note_fail
fi

# A copy of the index: layers b, c and e check staged content (not the working
# tree), and config files are found as committed.
TREE="$TMP/tree"
git -c core.autocrlf=false checkout-index -a --prefix="$TREE/" || fail_closed "cannot materialize the index"
mkdir -p "$TREE" || fail_closed "cannot create scratch directory"

if [ "$MODE" = "--staged" ]; then
  run_gitleaks staged staged git --staged "$ROOT"
else
  if git rev-parse -q --verify HEAD >/dev/null 2>&1; then
    run_gitleaks history history git --log-opts="--all" "$ROOT"
  fi
  # History alone misses what is not committed yet: also scan the index copy
  # and the working-tree version of every tracked file that differs from it.
  # gitleaks runs from inside each copy so reported paths are repo-relative.
  cd "$TREE" || fail_closed "cannot enter the index copy"
  run_gitleaks tree tree dir .
  cd "$ROOT" || fail_closed "cannot enter repository root"
  git diff --name-only --diff-filter=ACMRT -z >"$TMP/wtfiles"
  if [ -s "$TMP/wtfiles" ]; then
    "$PY" "$SCRIPT_DIR/layers.py" copy-files "$ROOT" "$TMP/wt" "$TMP/wtfiles" || fail_closed "cannot copy the working tree"
    cd "$TMP/wt" || fail_closed "cannot enter the working-tree copy"
    run_gitleaks working-tree worktree dir .
    cd "$ROOT" || fail_closed "cannot enter repository root"
  fi
fi

# ---- layers b and c: confcrypt check, SOPS metadata -----------------------
if [ "$MODE" = "--staged" ]; then
  git diff --cached --name-only --diff-filter=ACMR -z >"$TMP/files"
else
  git ls-files -z >"$TMP/files"
fi
"$PY" "$SCRIPT_DIR/layers.py" confcrypt "$TREE" "$TMP/files" >&2 || note_fail
"$PY" "$SCRIPT_DIR/layers.py" sops "$TREE" "$TMP/files" >&2 || note_fail
# identifying details: reported for manual review, never failing
"$PY" "$SCRIPT_DIR/layers.py" review "$TREE" "$TMP/files" >&2 || true

# ---- layer d (--all): no Ignored-set path may be tracked ------------------
if [ "$MODE" = "--all" ]; then
  git ls-files -ci --exclude-standard -z >"$TMP/ignored"
  if [ -s "$TMP/ignored" ]; then
    tr '\0' '\n' <"$TMP/ignored" | while IFS= read -r p; do
      echo "gate: ignored-set: tracked path must not be committed: $p" >&2
    done
    note_fail
  fi
fi

if [ "$STATUS" -eq 0 ]; then echo "gate: ok ($MODE)"; else echo "gate: FAILED ($MODE)" >&2; fi
exit "$STATUS"
