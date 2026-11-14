# Deploying the design

This repo describes a network design and holds the config and scripts that build it. It never holds the state of a running lab. To deploy the design, you supply the things only your site can decide (addresses of your Proxmox and OpenBao servers, node names, tokens, keys) and then run the layers in order.

This page covers the Proxmox VMs, which Terraform builds. Ansible roles, K3s workloads, TrueNAS apps and the router configs come later in the run order and are not described here yet.

## Design and site

- **The design** is in `Homelab Structure/`. `systems.yml` lists every host, with its interfaces, VLANs and resources. `vlans.yml` gives each VLAN its 802.1Q ID and subnets, and names the gateway of each subnet. The addressing is part of the design: a zone VLAN's subnet follows its ID, inside RFC 1918 space. If you change the design, change these files.
- **The site** is `Terraform/site.yml`. It holds only what changes from one deployment to the next. The file is gitignored. Copy `Terraform/site.example.yml` to start; every field in it has a comment.

Terraform reads both, so you edit YAML, not HCL. Adding or removing a VM in `systems.yml` adds or removes it in the next plan.

## What you supply

| Item | Used for | Where it goes |
|---|---|---|
| A Proxmox API token per cluster (`pve-internal`, `pve-dmz`) | Terraform creates the VMs. The clusters are never joined, so each has its own token. | OpenBao, at each cluster's `token_path`, with keys `token_id` and `token_secret`. During the bootstrap, pass it as variables (see below). |
| OpenBao | Holds the Proxmox tokens and the secrets the Ansible roles read. `bao1` runs it. | `openbao.address` in `site.yml`, and a token in `VAULT_TOKEN` (the provider does not read `BAO_TOKEN`), `~/.vault-token` or `-var bao_token=…` |
| The age key pair | Decrypts SOPS and confcrypt files. You need your own Daily and Backup keys (ADR 0002); the recipients in `.sops.yaml` are the owner's. | `~/.sops/keys.txt`, with your public keys in `.sops.yaml` |
| An SSH key | Ansible and you log in to the new VMs. | The cloud-init snippet below |
| A cloud-init template on every Proxmox node, and a snippet | Every VM is a full clone of the template. The snippet (vendor data) adds your user, SSH key and the guest agent. | `template` and `cicustom` per cluster in `site.yml` |

The template must have the QEMU guest agent and cloud-init, and the snippet must be on a storage that allows the `snippets` content type. The snippet is not in this repo because it carries your SSH key.

## Filling in site.yml

```sh
cp Terraform/site.example.yml Terraform/site.yml
```

Then, for each cluster under `clusters:`:

- `api_url`: the Proxmox API with scheme and port, such as `https://pve.example.lan:8006`. Leave off `/api2/json`.
- `nodes`: map each `host` value that `systems.yml` uses for that cluster (`pve1`…`pve4` for `pve-dmz`, `pve5`…`pve7` for `pve-internal`) to the Proxmox node name it runs on. A VM whose `host` is the group name itself needs an entry for the group name as well.
- `bridge`: a VLAN-aware bridge. Each NIC gets its VLAN tag from `vlans.yml`.
- `storage`, `template`, `cicustom`: where the disks go, what is cloned, and which snippet is used.
- `token_path`: where the token sits in OpenBao.
- `vmid_base`: VM IDs are computed as `vmid_base + 1000 × VLAN id + last octet` of the VM's first address (so `dns1`, at 192.168.16.2, is `vmid_base + 16002`). Adding a VM never renumbers another. To pin an ID, set `vms.<hostname>.vmid`.
- `dns` (optional): overrides the top-level `dns` block. The DMZ has no path to the internal resolvers, so it usually needs public ones.

`vms:` holds per-VM overrides: `vmid`, and `template` for a VM that isn't the default cloud-init image (such as `ha1`, which runs Home Assistant OS).

Some settings are not handled by Terraform. Configure these by hand after the first apply: `bao1`'s YubiKey (USB passthrough) and `secmon1`'s mirror NIC (PCI passthrough).

## The OpenBao bootstrap

Terraform normally reads each Proxmox token from OpenBao, but `bao1` is itself a VM that Terraform builds, in phase 2. So the first applies cannot use OpenBao:

1. Create the Proxmox API token for the cluster by hand (`pveum user token add …`, with the privileges to clone and configure VMs).
2. Run with `use_bao = false` and pass the token in. Set it in the environment, so that it stays out of shell history and files:

   ```sh
   cd Terraform/pve-internal
   terraform init
   export TF_VAR_use_bao=false
   export TF_VAR_proxmox_api_token_id='terraform@pve!deploy'
   read -rs TF_VAR_proxmox_api_token_secret && export TF_VAR_proxmox_api_token_secret
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

3. Bring up OpenBao on `bao1` (phase 2), then write each cluster's token to its `token_path`:

   ```sh
   bao kv put secret/proxmox/pve-internal/terraform token_id='…' token_secret='…'
   ```

4. Unset the `TF_VAR_` variables. From then on, run with the default `use_bao = true` and an OpenBao token. `terraform plan` should show no changes.

`bao_addr` overrides `openbao.address` from `site.yml` for one run.

## Run order

The phases are the `phase` values in `Homelab Structure/services.yml`. A phase starts once the one before it works.

| Phase | What | Layer |
|---|---|---|
| 1 | The network (routers, switches, VLANs) and the Proxmox clusters themselves, plus the bastion and NUT | Router configs, by hand |
| — | Every VM on both clusters, with `use_bao = false` | Terraform, `pve-internal/` then `pve-dmz/` |
| 2 | DNS (`dns1`), step-ca (`ca1`), OpenBao (`bao1`), Samba AD (`dc1`). Then the OpenBao bootstrap above. | Ansible |
| 3 | `file1` storage and shared databases, Authelia (`sso1`) | Ansible, TrueNAS |
| 4 | Prometheus and Grafana (`metrics1`) | Ansible |
| 5 | GitLab and runners (`devops1`, `runner1`) | Ansible |
| 7–8 | The K3s clusters and their apps (`k3s-app1`, `k3s-dmz1`) | Ansible, then Argo CD |
| 9–10 | Home Assistant, Frigate, Security Onion, CrowdSec | Ansible, appliances |

Terraform builds every VM in one apply, so the later phases find their machines ready. To build only one phase's VMs, target them, such as `terraform apply -target='module.vm["dns1"]'`.

`relay1` (Linode) and `lightsail1` aren't Proxmox VMs, so these roots skip them.

## Encrypted files and examples

When a file is encrypted with SOPS, you can't read it without the owner's key. So whoever adds a SOPS-governed file also commits a plaintext `*.example.yml` beside it with placeholder values, the way `site.example.yml` sits beside `site.yml`. Placeholders use RFC 5737 addresses (192.0.2.0/24, 198.51.100.0/24, 203.0.113.0/24) and `example.lan`.
