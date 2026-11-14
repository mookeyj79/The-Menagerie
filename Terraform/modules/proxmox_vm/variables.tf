variable "vm" {
  description = "One VM, as modules/design builds it from systems.yml, vlans.yml and site.yml."
  type = object({
    bridge      = string
    cicustom    = string
    cores       = number
    description = string
    disk_gb     = number
    memory_mb   = number
    name        = string
    nameservers = list(string)
    nics = list(object({
      gateway    = string
      ip_address = string
      prefix     = number
      vlan_id    = number
    }))
    node          = string
    search_domain = string
    storage       = string
    template      = string
    vmid          = number
  })

  validation {
    condition     = var.vm.vmid != null
    error_message = "No vmid: the VM has no address to compute one from. Set vms.<name>.vmid in site.yml."
  }

  validation {
    condition     = length(var.vm.nics) <= 16
    error_message = "Proxmox cloud-init configures at most 16 NICs (ipconfig0 to ipconfig15)."
  }
}
