# Scanning gate: one script in hook and CI, CI is the real gate, pinned gitleaks binary

The gate is a single POSIX-sh script, `Scripts/gate/gate.sh`. The `pre-commit` and `pre-merge-commit` hooks run it with `--staged`, and the GitHub Action runs it with `--all` (full history, the current tree including uncommitted changes, and the Ignored set). Three layers must all pass:

- gitleaks, with its default rules plus custom rules for the shapes the defaults miss
- `confcrypt check` over confcrypt-managed files
- a SOPS-metadata check over every SOPS-governed file

Identifying details (emails, public IPs, stray MACs) are reported for review and never fail the gate. The gate fails closed when a required tool is missing.

Keeping the local and CI checks in one script means they cannot diverge. The hook is only advisory: it can be skipped with `--no-verify`, and a fresh clone has no hook until it is installed. The enforcing check is therefore the CI job, made required by a branch ruleset on `main` that also blocks force-push and deletion.

## Considered Options

- **The official gitleaks GitHub Action.** Rejected: it trusts a third-party Action and a hard-coded default gitleaks version, and on push and PR events it scans only a commit range. Instead the workflow downloads a pinned gitleaks release (and sops), checks each against a hard-coded sha256 before running it, and installs the Python dependencies hash-pinned. `actions/checkout` is pinned by commit SHA, the job has `contents: read` only, and a weekly schedule re-scans the full history.
- **gitleaks alone.** Rejected: the audit found secret shapes it misses, and it cannot tell an encrypted confcrypt line or SOPS file from a plaintext one.
- **`.gitleaksignore` fingerprints for false positives.** Rejected: they contain line numbers and go stale. Reviewed exceptions use an inline `gitleaks:allow`, or a commented path entry in `.gitleaks.toml` where a file has no comments. The gate refuses a `.gitleaksignore`.

## Consequences

- Upgrading gitleaks or sops means changing both the version and the sha256 in `.github/workflows/gate.yml`.
- Each new clone must run the hook installer once (see the README). Clones that skip it are still caught by CI.
