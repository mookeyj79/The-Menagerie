output "vm_name" {
  value = proxmox_vm_qemu.auth1.name
}

output "vm_ip" {
  value = proxmox_vm_qemu.auth1.default_ipv4_address
}

output "vm_id" {
  value = proxmox_vm_qemu.auth1.vmid
}

output "vm_node" {
  value = proxmox_vm_qemu.auth1.target_node
}
