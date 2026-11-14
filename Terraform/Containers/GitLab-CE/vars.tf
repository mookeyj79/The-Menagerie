variable "use_vault" {
  description = "Flag for if Vault is Working or Not"
  type        = bool
  default     = true
}

variable "vault_addr" {
  description = "Address of the Hashicorp Vault Server"
  type        = string
  default     = "https://192.168.34.8:8200"
}

variable "vault_token" {
  description = "Hashicorp Vault Token for Terraform"
  type        = string
  sensitive   = true
  default     = "1234"
}

variable "remote_host" {
  description = "Address of the Docker Host to Configure"
  type        = string
}

variable "ssh_username" {
  description = "SSH User for Terraform"
  type        = string
  default     = "terraform"
}

variable "ssh_private_key_path" {
  description = "Private SSH Key for Terraform"
  type        = string
  sensitive   = true
  default     = "~/.ssh/terraform"
}

variable "apps_dir" {
  description = "Apps Directory"
  type        = string
  default     = "/opt/apps"
}

variable "secrets_dir" {
  description = "Secrets Directory"
  type        = string
  default     = "/opt/secrets"
}
