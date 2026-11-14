variable "apps_dir" {
  description = "Applications directory"
  type        = string
  default     = "/opt/apps"
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
