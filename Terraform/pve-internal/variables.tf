variable "bao_addr" {
  default     = null
  description = "OpenBao address; overrides openbao.address in site.yml."
  type        = string
}

variable "bao_token" {
  default     = null
  description = "OpenBao token able to read the Proxmox token path. Unset, the provider reads VAULT_TOKEN or ~/.vault-token."
  sensitive   = true
  type        = string
}

variable "proxmox_api_token_id" {
  default     = null
  description = "Proxmox API token ID (user@realm!name), used only when use_bao is false."
  sensitive   = true
  type        = string
}

variable "proxmox_api_token_secret" {
  default     = null
  description = "Proxmox API token secret, used only when use_bao is false."
  sensitive   = true
  type        = string
}

variable "use_bao" {
  default     = true
  description = "Read the Proxmox API token from OpenBao. False for the bootstrap, before bao1 exists."
  type        = bool
}
