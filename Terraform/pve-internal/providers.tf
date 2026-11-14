terraform {
  required_version = ">= 1.7.0"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }

    # The Vault provider talks to OpenBao unchanged.
    vault = {
      source  = "hashicorp/vault"
      version = ">= 4.7.0"
    }
  }
}

provider "proxmox" {
  pm_api_token_id     = local.proxmox_api_token_id
  pm_api_token_secret = local.proxmox_api_token_secret
  pm_api_url          = "${module.design.proxmox.api_url}/api2/json"
  pm_tls_insecure     = module.design.proxmox.tls_insecure
}

provider "vault" {
  address          = coalesce(var.bao_addr, module.design.openbao_address)
  skip_child_token = true
  token            = var.bao_token
}
