# Every VM in "Homelab Structure/systems.yml" placed on the pve-internal cluster: type vm, not
# decommissioned, with a host in the pve-internal group. Add or remove a VM there, not here.
module "design" {
  source = "../modules/design"

  cluster       = local.cluster
  site_file     = "${path.module}/../site.yml"
  structure_dir = "${path.module}/../../Homelab Structure"
}

module "vm" {
  source   = "../modules/proxmox_vm"
  for_each = module.design.vms

  vm = each.value
}

locals {
  cluster = "pve-internal"
}
