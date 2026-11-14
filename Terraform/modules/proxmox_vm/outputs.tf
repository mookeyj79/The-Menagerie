output "ipv4_address" {
  description = "Default IPv4 address the guest agent reports."
  value       = proxmox_vm_qemu.this.default_ipv4_address
}

output "vmid" {
  description = "Proxmox VM ID."
  value       = proxmox_vm_qemu.this.vmid
}
