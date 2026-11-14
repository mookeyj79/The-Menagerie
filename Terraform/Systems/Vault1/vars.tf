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