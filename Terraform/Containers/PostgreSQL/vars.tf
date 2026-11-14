
locals {
  hostname = split(".", var.remote_host)[0]
  postgresql_db = var.use_vault ? (
    data.vault_generic_secret.postgresql[0].data["db"]
  ) : var.postgresql_db

  postgresql_password = var.use_vault ? (
    data.vault_generic_secret.postgresql[0].data["password"]
  ) : var.postgresql_password

  postgresql_username = var.use_vault ? (
    data.vault_generic_secret.postgresql[0].data["username"]
  ) : var.postgresql_username
}

variable "postgresql_db" {
  description = "Default database for PostgreSQL"
  type        = string
  default     = "postgres"
}

variable "postgresql_password" {
  description = "Default password for PostgreSQL"
  type        = string
  sensitive   = true
  default     = "postgres"
}

variable "postgresql_username" {
  description = "Default user for PostgreSQL"
  type        = string
  default     = "postgres"
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

variable "use_vault" {
  description = "Flag for if Vault is Working or Not"
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
