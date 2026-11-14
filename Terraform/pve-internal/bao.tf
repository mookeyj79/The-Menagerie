# The Proxmox API token for this cluster, from OpenBao (KV with token_id and token_secret at the
# token_path in site.yml). bao1 is built in phase 2, so the first applies run with use_bao = false
# and the token passed in (docs/deploy.md).
data "vault_generic_secret" "proxmox_api_token" {
  count = var.use_bao ? 1 : 0
  path  = module.design.proxmox.token_path
}

locals {
  proxmox_api_token_id = var.use_bao ? (
    data.vault_generic_secret.proxmox_api_token[0].data["token_id"]
  ) : var.proxmox_api_token_id

  proxmox_api_token_secret = var.use_bao ? (
    data.vault_generic_secret.proxmox_api_token[0].data["token_secret"]
  ) : var.proxmox_api_token_secret
}
