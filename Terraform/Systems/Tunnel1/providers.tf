terraform {
  required_version = ">= 0.13.0"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }

    vault = {
      source  = "hashicorp/vault"
      version = ">= 4.7.0"    
    }
  }
}

provider "proxmox" {
  pm_api_url          = "${var.proxmox_host}/api2/json"
  pm_tls_insecure     = true
  pm_api_token_id     = local.proxmox_api_token_id
  pm_api_token_secret = local.proxmox_api_token_secret
}

provider "vault" {
  address          = coalesce(var.vault_addr, "")
  token            = coalesce(var.vault_token, "")
  skip_child_token = true
}
