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

The hooks can be skipped with `--no-verify`, but that only defers the failure. The GitHub Action (`.github/workflows/gate.yml`) runs `gate.sh --all` over the full history and tree, and the `main` branch ruleset requires that check to pass. To run the same check locally, use `sh Scripts/gate/gate.sh --all`.

## Restore the Backup key for a rebuild

Encrypted files can be decrypted with either the Daily key or the Backup key (see [ADR 0002](docs/adr/0002-age-key-layout.md)). A disaster-recovery rebuild uses the Backup key, which serves as the DR key. Its private half is kept offline as a passphrase-protected age file, on a USB stick and as a printed copy. The steps below assume Linux on the rebuild machine.

1. Decrypt the Backup key to the standard key path. Enter its passphrase when asked:

   ```sh
   mkdir -p "$HOME/.sops" && chmod 700 "$HOME/.sops"
   (umask 077; age -d -o "$HOME/.sops/keys.txt" /path/to/usb/backup-key.age)
   ```

   If the USB stick is lost, type the printed copy into a file and decrypt that file instead.

2. Run the rebuild:

   ```sh
   cd Disaster_Recovery
   ./Deploy_Recovery.sh
   ```

   `Deploy_Recovery.sh` reads the key from `$SOPS_AGE_KEY_FILE`, which defaults to `$HOME/.sops/keys.txt`. If the key is missing, it stops before doing anything. It decrypts the SOPS-encrypted `host_vars` files (`vault1.yml`, `auth1.yml`, `seeder1.yml`) with `sops` before it uses them. If you put the key somewhere else, export `SOPS_AGE_KEY_FILE` first.

3. Shred the key when the rebuild is done, whether it succeeded or failed:

   ```sh
   shred -u "$HOME/.sops/keys.txt"
   ```

   Also delete any typed-in copy of the printed key the same way. The Backup key stays offline. It never goes into CI, Vault or the repo.

To set up a new Daily key on the workstation after a rebuild, generate it with `age-keygen -o ~/.sops/keys.txt` and add its public half to `.sops.yaml`. Then, from a machine that holds the Backup key, run `sops updatekeys <file>` for each SOPS-governed file and `python Scripts/confcrypt/confcrypt.py rekey <file>` for each confcrypt-managed file.
