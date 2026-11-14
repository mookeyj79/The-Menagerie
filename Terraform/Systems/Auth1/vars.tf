locals {
  proxmox_api_token_id = var.use_vault ? (
    data.vault_generic_secret.proxmox_api_token[0].data["token_id"]
  ) : var.proxmox_api_token_id

  proxmox_api_token_secret = var.use_vault ? (
    data.vault_generic_secret.proxmox_api_token[0].data["token_secret"]
  ) : var.proxmox_api_token_secret
}

variable "proxmox_api_token_id" {
  description = "API Token ID for Proxmox Access"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "API Token Secret for Proxmox Access"
  type        = string
  sensitive   = true
}

variable "proxmox_host" {
  description = "Address of the Proxmox Server"
  type        = string
  default     = "192.168.1.1:8006"
}

variable "proxmox_pve_node" {
  description = "Proxmox VM Manager"
  type        = string
  default     = "pve1"
}

variable "use_vault" {
  description = "Vault Flag"
  type        = bool
  default     = true
}

variable "vault_addr" {
  description = "Address of the Hashicorp Vault Server"
  type        = string
  default     = "http://192.168.1.1:8200"
}

variable "vault_token" {
  description = "Hashicorp Vault Token for Terraform"
  type        = string
  sensitive   = true
}
