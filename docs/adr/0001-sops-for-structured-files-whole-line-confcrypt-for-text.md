# SOPS for structured files, whole-line confcrypt for unstructured text

Secrets committed to git are protected by two tools that share one set of age recipients. Structured files (YAML, JSON, dotenv) are encrypted with SOPS, with every value encrypted and key names left readable, so a secret under an unexpected key name cannot stay plaintext. Unstructured text that SOPS can only treat as an opaque binary blob (router configs, notes files) is encrypted with confcrypt, which works one whole line at a time: a rule is a regex that matches a whole line plus a fixed dummy line, and the original line is age-encrypted into a metadata line directly above the dummy that replaces it.

## Considered Options

- **SOPS for everything.** Rejected: SOPS treats any unrecognised extension (`.rsc`, `.ios`, `.txt`, also `.tfvars`) as binary, so the whole file becomes one blob. Diffs are unreadable, and a router config is no longer a file you can read or review.
- **SOPS with `encrypted_regex`** (encrypt only "secret-looking" keys). Rejected: a secret stored under a key the regex does not expect stays plaintext.
- **confcrypt v1: capture groups and inline placeholder tokens.** Rejected: it leaked the tail of quoted values that contain spaces and needed a match cap. Encrypting the whole line removes both by design.
- **Deterministic encryption** to keep diffs quiet. Rejected in favour of standard randomized age encryption. `confcrypt edit` reuses the existing ciphertext for unchanged lines, so editing one line changes one blob, and only `rekey` rewrites every blob.

## Consequences

- Recipients come from `.sops.yaml` only. confcrypt reads them from there, so the two tools cannot drift apart. Recipients change with `sops updatekeys` for SOPS files and `confcrypt rekey` for text files.
- A protected line is hidden completely in diffs, so confcrypt rules are written narrowly. A per-dialect tripwire catches suspicious lines that no rule covers.
- Files under confcrypt live in the tree encrypted only and are edited through `confcrypt edit`. Plaintext never exists in a commit.
- `.tfvars` and other formats SOPS cannot parse are not encrypted. Secrets stay out of them.
- Neither tool is linked to Vault. They only protect files committed to git.
