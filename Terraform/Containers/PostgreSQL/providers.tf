terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.3.0"
    }

    vault = {
      source = "hashicorp/vault"
      version = ">= 4.7.0"    
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

provider "vault" {
  address = coalesce(var.vault_addr, "")
  token = coalesce(var.vault_token, "")
  skip_child_token = true
}
