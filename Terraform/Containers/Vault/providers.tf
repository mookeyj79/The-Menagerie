terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.3.0"
    }
  }
}

provider "docker" {
  host = "ssh://${var.ssh_username}@${var.remote_host}:22"
  ssh_opts = [
    "-o", "StrictHostKeyChecking=no", 
    "-o", "UserKnownHostsFile=/dev/null", 
    "-o", "IdentitiesOnly=yes", 
    "-i", var.ssh_private_key_path ]
}
