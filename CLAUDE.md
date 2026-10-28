# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

"The Menagerie" is a personal homelab infrastructure-as-code repo (Proxmox VMs, Docker containers, MikroTik/Cisco routers). It is configuration, not an application: there is no build system, test suite, or linter config checked in. Most top-level directories are currently untracked in git (only `README.md` and `LICENSE` are committed).

## Layers and how they connect

The homelab is built in layers, each in its own top-level directory:

1. **`Homelab Structure/`** — YAML sources of truth (`systems.yml`, `services.yml`, `vlans.yml`, `dns.yml`, `fw_rules.yml`, `fw_groups.yml`, `bastion_access.yml`, `proxy_allowlist.yml`). Each file documents its own schema in a header comment. `systems.yml` lists every host with its `ansible_roles` (applied on top of the base image); `services.yml` maps services to hosts, deploy `phase`, and dependencies. Check these first to learn what a host or service is supposed to be, and update them when adding/changing hosts or services.
2. **`Golden Images/`** — Packer templates (`packer/templates/*.pkr.hcl`, one per image: debian13-base, raspbian-base, ca1, db1, devops1, seeder1), `image_plan.yml`, and builder/deployer shell scripts in `scripts/`. Produces the base images that VMs are cloned from.
3. **`Terraform/`** — Proxmox (`proxmox_vm_qemu`) resources, split into `Systems/` (one dir per VM: Auth1, DB1, DevOps1, Seeder1, Tunnel1, Vault1), `Networks/` (Docker networks: DNS_Net, Main_Net, Socket-Proxy_Net), and `Containers/` (one dir per container: AdGuard, GitLab-CE, PostgreSQL, Redis, Step_CA, Tailscale, Unbound, Vault). Each dir is its own root module with `main.tf`/`providers.tf`/`vars.tf`.
4. **`Ansible/`** — roles only (no playbooks/inventory here), grouped by purpose:
   - `Systems/` — OS-level roles named `linux_*`, each with per-distro task files (`alpine.yml`, `debian.yml`, `redhat.yml`) dispatched from `tasks/main.yml`.
   - `Containers/` — one role per service (adguard, gitlab-ce, lego, postgresql, redis, step_ca, tailscale, traefik, unbound, vault); these prepare users/dirs/config and deploy the container, using `linux_manage_accounts` and `generic_check_docker`.
   - `Helpers/` — shared roles. `generic_build_vars` has a resolver pattern (`tasks/resolvers/*.yml` with `_resolve_map.yml`/`_resolve_object.yml` and Jinja macros) that builds role variables, pulling secrets from Vault.
5. **`Disaster_Recovery/`** — `Build_Recovery.sh` assembles `DR_Dir/` (a self-contained copy of the Ansible roles + Terraform + `ansible.cfg`, `site.ini`, `stage_one.yml`, `stage_two.yml`, `host_vars/`) from `Templates/`; `Deploy_Recovery.sh` uses it to rebuild the lab from scratch. **`DR_Dir/` is a generated copy** of `Ansible/` and `Terraform/` — edit the originals (and `Templates/`), not `DR_Dir/`. The stage playbooks are partly commented out to select which roles run during a given recovery.
6. **`Router Configs/`** — current RouterOS (`Router1/2_v3_4.rsc`) and Cisco IOS (`Router3_v3_4.ios`) configs, backups, and `OLD/` history. Versioned by filename suffix; new revisions get a new file rather than editing in place.

## Secrets

- Secrets live in HashiCorp Vault. `Homelab Scripts/` holds helpers (`Write-VaultSecret.ps1`, `Write_VaultSecret.sh`, `dump_vault.ps1`, `clone_homelab.ps1`), and `Secrets Layout.txt` documents the Vault path layout. `vault_backup.json` / `vault_secrets.json` in that directory are secret dumps — do not read, print, or commit them.
- Router configs are protected with **`Scripts/confcrypt/confcrypt.py`**, which age-encrypts sensitive values inline (replacing them with `<PLACEHOLDER>` tokens plus a `# confcrypt ...` comment line above). Patterns are defined per file extension in `Router Configs/.confcrypt.yml`. Usage:
  ```
  python Scripts/confcrypt/confcrypt.py encrypt|decrypt <file> [--in-place | -o OUT] [--backup]
  python Scripts/confcrypt/confcrypt.py edit <file>
  ```
  Identity key is a path (`--identity`, `$SOPS_AGE_KEY_FILE`, config, or `~/.sops/keys.txt`); keys are never passed as arguments. Don't hand-edit lines near `confcrypt` comments.
- Some Terraform files contain placeholder/bootstrap values (e.g. cloud-init passwords in `Terraform/Systems/*/main.tf`); don't propagate them into new files.

## Conventions

- Ansible roles follow standard layout (`defaults/`, `tasks/`, `meta/`, `templates/`, `files/`, `handlers/`) with `galaxy_info` namespace `mookeyj`. Container roles use `apps_dir/<service>` for data and fixed service UIDs (e.g. vault uid 2008).
- Terraform attributes are alphabetized within resources.
- Scripts target Linux hosts and source `/opt/scripts/libs/colors.shlib`; the repo is edited on Windows (PowerShell/Git Bash), so shell scripts must keep LF line endings.

## Agent skills

### Issue tracker

Issues are tracked in GitHub Issues (mookeyj79/The-Menagerie) via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default vocabulary (needs-triage, needs-info, ready-for-agent, ready-for-human, wontfix). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.
