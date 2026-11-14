# Glossary

**confcrypt**: The repo's tool for protecting secrets in unstructured text files that SOPS cannot handle. Structured data (YAML, JSON, dotenv, ini) goes to SOPS; everything else goes to confcrypt.

**Dialect**: A confcrypt filetype definition: a comment style, the files it applies to, and its rules. Selected by file glob first, then by extension.

**Rule**: A dialect entry pairing a line regex with a dummy line. Every line matching the regex is protected.

**Dummy line**: The fixed, harmless line that stands in for a protected line in the committed file. It reveals nothing about the original.

**Metadata line**: The comment line directly above a dummy line, carrying the age-encrypted original line.

**Encrypted line**: A line that is a dummy line with a metadata line directly above it. Only this pairing counts, so a dummy that matches its own rule's regex is not mistaken for plaintext.

**Tripwire**: A broad per-dialect regex that flags suspicious lines no rule covers, so unknown secret types fail the check instead of passing silently.

**Check**: The key-less confcrypt command that fails if any protected line is still plaintext. It runs in the git hook and the GitHub Action.

**Rekey**: Re-encrypting every metadata line to a changed recipient list. The only operation expected to rewrite every ciphertext.

**Daily key**: The age keypair used day to day on the workstation. Its private half never leaves that machine.

**Backup key**: The second age keypair, kept offline. Every encrypted file is also readable with it, and it is the key to use when the Daily key is lost or unavailable.

**Gate**: The set of checks that must pass before a change can enter the repo: a gitleaks secret scan (staged changes in the hook; full history plus the current tree in CI), the confcrypt check over confcrypt-managed files, the SOPS-encrypted check over SOPS-governed files, a refusal of any `.gitleaksignore`, and in CI that no Ignored-set path is tracked. It also reports identifying details (emails, public IPs, MACs) for review without failing. It runs in the `pre-commit` and `pre-merge-commit` hooks for staged changes and in CI for everything.

**Ignored set**: The paths gitignored because they are superseded copies, secret dumps, key files or state files: every `OLD/` folder, the Vault dumps, `Homelab Scripts/Secrets/`, `Router Configs/Backups/`, age key files, and Terraform state, plans, crash logs and `.tfvars` variable files. CI fails if any of them is tracked.

**SOPS-governed file**: A file whose path matches a rule in `.sops.yaml`. It must carry SOPS metadata before it can be committed.

**Game stream source**: A PC that renders a game and streams it to a game stream client, using either Sunshine (for Moonlight) or Steam Remote Play (for Steam Link).

**Game stream client**: A device, in practice a smart TV, that runs Moonlight or Steam Link and displays a stream from a game stream source. It always initiates the connection.

**Cutover**: The one-time sequence that takes the working tree from plaintext secrets to a state safe for its first push to GitHub.

**Decrypt rehearsal**: A cutover check that encrypts scratch copies of the real files, decrypts them with each key alone, and compares them byte for byte to the originals. It proves recovery works before any live file is encrypted.
