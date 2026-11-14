# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

"The Menagerie" is a personal homelab infrastructure-as-code repo (Proxmox VMs, Docker containers, MikroTik/Cisco routers). It is configuration, not an application: there is no build system, test suite, or linter config checked in. Most top-level directories are currently untracked in git (only `README.md` and `LICENSE` are committed).

## Layers and how they connect

The homelab is built in layers, each in its own top-level directory:

1. **`Homelab Structure/`** — YAML sources of truth (`systems.yml`, `services.yml`, `vlans.yml`, `dns.yml`, `fw_rules.yml`, `fw_groups.yml`, `bastion_access.yml`, `proxy_allowlist.yml`). Each file documents its own schema in a header comment. `systems.yml` lists every host with its `ansible_roles`; `services.yml` maps services to hosts, deploy `phase`, and dependencies. Check these first to learn what a host or service is supposed to be, and update them when adding/changing hosts or services.
2. **`Terraform/`** — Proxmox (`proxmox_vm_qemu`) resources, split into `Systems/` (one dir per VM: Auth1, DB1, DevOps1, Seeder1, Tunnel1, Vault1), `Networks/` (Docker networks: DNS_Net, Main_Net, Socket-Proxy_Net), and `Containers/` (one dir per container: AdGuard, GitLab-CE, PostgreSQL, Redis, Step_CA, Tailscale, Unbound, Vault). Each dir is its own root module with `main.tf`/`providers.tf`/`vars.tf`.
3. **`Ansible/`** — roles only (no playbooks/inventory here), grouped by purpose:
   - `Systems/` — OS-level roles named `linux_*`, each with per-distro task files (`alpine.yml`, `debian.yml`, `redhat.yml`) dispatched from `tasks/main.yml`.
   - `Containers/` — one role per service (adguard, gitlab-ce, lego, postgresql, redis, step_ca, tailscale, traefik, unbound, vault); these prepare users/dirs/config and deploy the container, using `linux_manage_accounts` and `generic_check_docker`.
   - `Helpers/` — shared roles. `generic_build_vars` has a resolver pattern (`tasks/resolvers/*.yml` with `_resolve_map.yml`/`_resolve_object.yml` and Jinja macros) that builds role variables, pulling secrets from Vault.
4. **`Router Configs/`** — current RouterOS (`Router1/2_v3_5.rsc`) and Cisco IOS (`Router3_v3_5.ios`) configs (confcrypt-encrypted), backups, and `OLD/` history. Versioned by filename suffix; new revisions get a new file rather than editing in place.

## Secrets

- Secrets live in HashiCorp Vault. Never read, print or commit a Vault dump (`vault_backup.json`, `vault_secrets.json`); they are in the Ignored set.
- Structured files (YAML, JSON, dotenv, ini) are encrypted with **SOPS**; `.sops.yaml` holds the creation rules and the age recipients (daily key and Backup key, see ADR 0002). Use `sops edit <file>` on a SOPS-governed file rather than writing plaintext into it.
- Unstructured text (router configs, the Wi-Fi notes file) is protected with **confcrypt v2** (`Scripts/confcrypt/confcrypt.py`). Rules are whole-line: each dialect in `Router Configs/.confcrypt.yml` pairs a line regex with a fixed dummy line, and every matching line is replaced whole by its dummy (for MAC rules, a *masked* dummy: the original line with only the MAC zeroed, prefixed `REDACTED`, ADR 0004), with the age-encrypted original in a metadata comment line directly above (`# confcrypt v2 <blob>`, `!` for Cisco). Recipients come from `.sops.yaml`. Usage:
  ```
  python Scripts/confcrypt/confcrypt.py encrypt|decrypt|rekey <file> [--in-place [--backup] | -o OUT]
  python Scripts/confcrypt/confcrypt.py encrypt <file> --dry-run
  python Scripts/confcrypt/confcrypt.py edit <file>
  python Scripts/confcrypt/confcrypt.py check <file>...
  ```
  `check` is key-less. The identity is a path (`--identity`, `$SOPS_AGE_KEY_FILE`, config, or `~/.sops/keys.txt`); keys are never passed as arguments. Change protected lines with `edit`, leaving metadata/dummy pairs untouched by hand.
- The **gate** (`Scripts/gate/gate.sh`, ADR 0003) runs from the `pre-commit` and `pre-merge-commit` hooks (`--staged`) and in CI (`--all`). It must pass; reviewed false positives go in `.gitleaks.toml` or an inline `gitleaks:allow`.
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
