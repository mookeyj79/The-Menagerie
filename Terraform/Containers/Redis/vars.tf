variable "apps_dir" {
  description = "Apps Directory"
  type        = string
  default     = "/opt/apps"
}

variable "redis_use_tls" {
  description = "Whether to use TLS for Redis connections"
  type        = bool
  default     = false
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

locals {
  hostname = split(".", var.remote_host)[0]
}
