terraform {
  required_version = ">= 0.13.0"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "${var.proxmox_host}/api2/json"
  pm_tls_insecure     = true
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
}
