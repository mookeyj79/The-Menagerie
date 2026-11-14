output "vm_name" {
  value = proxmox_vm_qemu.seeder1.name
}

output "vm_ip" {
  value = proxmox_vm_qemu.seeder1.default_ipv4_address
}

output "vm_id" {
  value = proxmox_vm_qemu.seeder1.vmid
}

output "vm_node" {
  value = proxmox_vm_qemu.seeder1.target_node
}
