output "vms" {
  description = "Each VM built on this cluster, with its vmid and the address the guest agent reports."
  value = {
    for name, vm in module.vm : name => {
      ipv4_address = vm.ipv4_address
      vmid         = vm.vmid
    }
  }
}
