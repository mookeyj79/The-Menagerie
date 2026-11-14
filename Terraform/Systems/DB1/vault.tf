data "vault_generic_secret" "proxmox_api_token" {
  count = var.use_vault ? 1 : 0
  path = "secret/systems/${var.proxmox_pve_node}/api_tokens/terraform"
}
