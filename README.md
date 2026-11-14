# The-Menagerie
My Homelab Structure and Build Files

## Install the git hooks

Every commit is checked by the scanning gate (`Scripts/gate/gate.sh`, see [ADR 0003](docs/adr/0003-scanning-gate.md)). The hooks live in the tracked `.githooks/` directory. Git does not turn them on by itself, so run this once in each fresh clone:

```sh
# Linux / macOS / Git Bash
sh Scripts/install-hooks.sh
```

```powershell
# Windows PowerShell
.\Scripts\install-hooks.ps1
```

Both scripts set `core.hooksPath` to `.githooks`. From then on, two thin hooks run `gate.sh --staged` on what you are about to commit: `pre-commit` for ordinary commits and `pre-merge-commit` for merge commits.

The gate fails closed if a tool it needs is missing. Put these on `PATH` first:

- `gitleaks` 8.30.1 (the version CI uses)
- `sops`
- Python 3 with `pyyaml` and `pyrage`

Instead of `PATH`, the gate also honours `GATE_GITLEAKS`, `GATE_SOPS` and `GATE_PYTHON` (full paths, forward slashes on Windows). With only [uv](https://docs.astral.sh/uv/) installed, point `GATE_PYTHON` at a venv:

```powershell
$v = "$env:USERPROFILE\.venvs\menagerie"
uv venv $v
uv pip install --python "$v\Scripts\python.exe" pyyaml pyrage
[Environment]::SetEnvironmentVariable('GATE_PYTHON', ("$v\Scripts\python.exe" -replace '\\', '/'), 'User')
```

Open a new terminal afterwards. To run `confcrypt.py` by hand, activate the venv first (`& "$v\Scripts\Activate.ps1"`).

The hooks can be skipped with `--no-verify`, but that only defers the failure. The GitHub Action (`.github/workflows/gate.yml`) runs `gate.sh --all` over the full history and tree, and the `main` branch ruleset requires that check to pass. To run the same check locally, use `sh Scripts/gate/gate.sh --all`.

## Restore the Backup key

Encrypted files can be decrypted with either the Daily key or the Backup key (see [ADR 0002](docs/adr/0002-age-key-layout.md)). Use the Backup key when the Daily key is lost or on a machine that has none. Its private half is kept offline as a passphrase-protected age file, on a USB stick and as a printed copy. The steps below assume Linux.

1. Decrypt the Backup key to the standard key path. Enter its passphrase when asked:

   ```sh
   mkdir -p "$HOME/.sops" && chmod 700 "$HOME/.sops"
   (umask 077; age -d -o "$HOME/.sops/keys.txt" /path/to/usb/backup-key.age)
   ```

   If the USB stick is lost, type the printed copy into a file and decrypt that file instead.

2. Use it. `sops` and `confcrypt.py` read the key from `$SOPS_AGE_KEY_FILE`, which defaults to `$HOME/.sops/keys.txt`, for example `python Scripts/confcrypt/confcrypt.py decrypt "Router Configs/Router1_v3_5.rsc" -o /path/outside/the/repo`.

3. Shred the key when you are done, whether the work succeeded or failed:

   ```sh
   shred -u "$HOME/.sops/keys.txt"
   ```

   Also delete any typed-in copy of the printed key the same way. The Backup key stays offline. It never goes into CI, Vault or the repo.

To set up a new Daily key on a workstation, generate it with `age-keygen -o ~/.sops/keys.txt` and add its public half to `.sops.yaml`. Then, from a machine that holds the Backup key, run `sops updatekeys <file>` for each SOPS-governed file and `python Scripts/confcrypt/confcrypt.py rekey <file>` for each confcrypt-managed file.
