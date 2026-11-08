# age key layout: daily key, offline backup key as DR key, no key in CI or Vault

Every SOPS file and every confcrypt metadata line is encrypted to two age recipients. Each one can decrypt on its own.

- **Daily key.** Generated on, and kept only on, the owner's workstation at `~/.sops/keys.txt` (`%USERPROFILE%\.sops\keys.txt` on Windows). It is rotated only when a compromise is suspected.
- **Backup key.** Its public half is listed in `.sops.yaml`. Its private half is passphrase-protected with `age -p` and kept offline, on a USB stick plus a printed copy. The backup key is also the disaster-recovery (DR) key: a rebuild machine decrypts it to the standard key path, uses it, and shreds it (see the README).

No private key is stored in CI, in GitHub secrets or in Vault. CI only runs checks that need no key (the gate). A compromised GitHub account or a compromised Vault therefore cannot decrypt anything in the repo. Vault also cannot be the place that holds the key needed to rebuild Vault.

## Considered Options

- **One key only.** Rejected: losing the workstation would lock the owner out of every encrypted file.
- **Key in CI or Vault** for automated decryption. Rejected: it widens the attack surface to GitHub or Vault, and nothing in CI needs plaintext.
- **SOPS's default key path** (`%AppData%\sops\age\keys.txt` or `$XDG_CONFIG_HOME/sops/age/keys.txt`). Rejected in favour of one path on every OS that confcrypt already uses by default. For SOPS, set `SOPS_AGE_KEY_FILE` to that path.

## Consequences

- Moving to a new workstation: generate a fresh daily key, add its public half to `.sops.yaml`, then run `sops updatekeys` and `confcrypt rekey` from a machine that holds the backup key.
- The backup key's passphrase and its offline copies are now part of the DR plan. If both offline copies and the workstation are lost together, the encrypted files are unrecoverable.
