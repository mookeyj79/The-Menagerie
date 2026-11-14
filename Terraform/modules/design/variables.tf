variable "cluster" {
  description = "Name of the Proxmox cluster: a group in systems.yml and a key under clusters in site.yml."
  type        = string
}

variable "site_file" {
  description = "Path to the deployer's site.yml."
  type        = string
}

variable "structure_dir" {
  description = "Directory holding the design: systems.yml and vlans.yml."
  type        = string
}
