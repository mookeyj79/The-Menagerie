output "openbao_address" {
  description = "OpenBao address from site.yml (scheme, host and port)."
  value       = local.site.openbao.address
}

output "proxmox" {
  description = "How to reach this cluster's Proxmox API: URL with scheme and port, TLS check, OpenBao token path."
  value = {
    api_url      = local.cluster.api_url
    tls_insecure = try(local.cluster.tls_insecure, false)
    token_path   = local.cluster.token_path
  }
}

output "vms" {
  description = "The VMs to build on this cluster, keyed by hostname."
  value       = local.vms

  precondition {
    condition     = length(local.unresolved_gateways) == 0
    error_message = "Gateway not resolvable through systems.yml; set gateway_interface in vlans.yml: ${join(", ", local.unresolved_gateways)}"
  }
}
