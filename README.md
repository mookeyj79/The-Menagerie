# The-Menagerie

Infrastructure as code for a segmented Proxmox homelab: the network design as YAML, Terraform that builds the VMs from it, Ansible roles that configure them, and the router configs.

[![gate](https://github.com/mookeyj79/The-Menagerie/actions/workflows/gate.yml/badge.svg)](https://github.com/mookeyj79/The-Menagerie/actions/workflows/gate.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Overview

The repo is built in layers. Each layer reads the one above it, so a change to the design starts in the YAML.

- **The design** (`Homelab Structure/`): every host and network device, VLAN, DNS record, firewall group and rule, cable, bastion access policy, and which service runs where in which build phase. Each file documents its own schema in its header comment.
- **Terraform** (`Terraform/`): one root per Proxmox cluster (`pve-internal`, `pve-dmz`) builds every VM straight from `systems.yml` and `vlans.yml`. No address, VM ID, node or VLAN tag is written in HCL.
- **Ansible roles** (`Ansible/`): OS roles (hardening, updates, Docker, backups, shell setup) for Alpine, Debian and Red Hat, and one role per containerized service (AdGuard, GitLab CE, lego, PostgreSQL, Redis, step-ca, Tailscale, Traefik, Unbound, Vault). Secrets are pulled from Vault/OpenBao at run time.
- **Router configs** (`Router Configs/`): RouterOS and Cisco IOS configs, with secret lines encrypted by confcrypt.
- **A scanning gate** (`Scripts/gate/`): runs on every commit and in CI, so no plaintext secret reaches git.

> [!NOTE]
> This is a blueprint, not a backup. It never holds the state of a running lab. To deploy it, you supply your own site values (server addresses, node names, tokens, keys). Encrypted lines can only be read with the owner's age keys, so you bring your own keys too.

## Repository layout

| Path | Contents |
|---|---|
| [`Homelab Structure/`](Homelab%20Structure/) | Sources of truth: `systems.yml`, `vlans.yml`, `services.yml`, `dns.yml`, `fw_groups.yml`, `fw_rules.yml`, `links.yml`, `bastion_access.yml` |
| [`Terraform/`](Terraform/) | `pve-internal/` and `pve-dmz/` roots, the `design` module (reads the YAML) and the `proxmox_vm` module; `site.example.yml` is the template for your site values |
| [`Ansible/`](Ansible/) | Roles only: `Systems/`, `Containers/`, `Helpers/` |
| [`Router Configs/`](Router%20Configs/) | Current router configs and the confcrypt rules (`.confcrypt.yml`) |
| [`Scripts/`](Scripts/) | `confcrypt/` (line-level encryption for text configs), `gate/` (the scanning gate), hook installers, `ios_diff_config.py` (prints the IOS commands that turn one config into another) |
| [`docs/`](docs/) | [Deploy guide](docs/deploy.md) and [architecture decision records](docs/adr/) |
| [`GLOSSARY.md`](GLOSSARY.md) | The terms used across the repo |

## Requirements

- Proxmox VE clusters with a cloud-init template on every node
- OpenBao (or Vault), for the Proxmox tokens and the secrets the Ansible roles read
- Terraform 1.7 or later (providers: `telmate/proxmox` 3.0.2-rc07, `hashicorp/vault` 4.7 or later)
- Ansible, to run the roles from your own playbooks and inventory
- [age](https://age-encryption.org) keys, [SOPS](https://getsops.io) and Python 3 with `pyyaml` and `pyrage`, for the encrypted files
- For committing: `gitleaks` 8.30.1 (see [Install the git hooks](#install-the-git-hooks))

## Quick start

The full walkthrough, including the OpenBao bootstrap and the build phases, is in [docs/deploy.md](docs/deploy.md). In short:

1. Copy the site template and fill it in. Every field has a comment.

   ```sh
   cp Terraform/site.example.yml Terraform/site.yml
   ```

2. Build the VMs, one cluster at a time. On the first run OpenBao doesn't exist yet, so pass the Proxmox token in with `use_bao = false` as the deploy guide shows.

   ```sh
   cd Terraform/pve-internal
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

3. Configure the VMs with the Ansible roles, phase by phase, in the order `services.yml` gives.

To add or remove a VM, edit `Homelab Structure/systems.yml` and plan again.

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

## Development

Run the gate over the whole tree and history, as CI does:

```sh
sh Scripts/gate/gate.sh --all
```

The confcrypt and gate tests use pytest, with the same Python the gate uses:

```sh
python -m pytest Scripts
```

The `design` module has Terraform tests with fixtures:

```sh
cd Terraform/modules/design
terraform init -backend=false
terraform test
```

The [gate workflow](.github/workflows/gate.yml) runs `gate.sh --all` on every push and pull request, and weekly. The [tests workflow](.github/workflows/tests.yml) runs pytest and `terraform test` on every push and pull request. Both install their tools (gitleaks, SOPS, Terraform) with pinned checksums, and the Python packages from the hash-pinned [`.github/gate-requirements.txt`](.github/gate-requirements.txt) and [`.github/test-requirements.txt`](.github/test-requirements.txt).

Shell scripts must keep LF line endings: they run on Linux hosts, though the repo is edited on Windows too. Design decisions are recorded in [`docs/adr/`](docs/adr/).

## License

[MIT](LICENSE)
