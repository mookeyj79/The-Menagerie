locals {
  site      = yamldecode(file(var.site_file))
  cluster   = local.site.clusters[var.cluster]
  overrides = try(local.site.vms, null) == null ? {} : local.site.vms

  systems = yamldecode(file("${var.structure_dir}/systems.yml"))
  vlans   = { for v in yamldecode(file("${var.structure_dir}/vlans.yml")).vlans : v.name => v }

  hosts = { for s in local.systems.systems : s.hostname => s }

  group      = one([for g in local.systems.groups : g if g.name == var.cluster])
  placements = concat(local.group.hosts, [local.group.name])

  vm_systems = {
    for s in local.systems.systems : s.hostname => s
    if s.type == "vm" && s.state != "decommissioned" && contains(local.placements, try(s.host, ""))
  }

  # Each subnet with its prefix length and the gateway address resolved through systems.yml
  # (gateway_host, then gateway_interface, or the host's only interface), as vlans.yml defines.
  subnets = {
    for name, v in local.vlans : name => [
      for sn in v.subnets : {
        cidr = sn.cidr
        gateway = try(sn.gateway_host, null) == null ? null : one([
          for i in local.hosts[sn.gateway_host].interfaces : i.ip_address
          if try(i.name == sn.gateway_interface, length(local.hosts[sn.gateway_host].interfaces) == 1)
        ])
        gateway_host = try(sn.gateway_host, null)
        prefix       = tonumber(split("/", sn.cidr)[1])
      }
    ]
  }

  # Subnets naming a gateway_host whose address could not be resolved: the host has several
  # interfaces and no gateway_interface picks one (vlans.yml requires it then), or none matches.
  unresolved_gateways = flatten([
    for name, sns in local.subnets : [
      for sn in sns : "${name} ${sn.cidr} (${sn.gateway_host})" if sn.gateway_host != null && sn.gateway == null
    ]
  ])

  # Proxmox NICs: every interface on a VLAN, in systems.yml order. Interfaces with no VLAN
  # (overlays such as tailscale0, PCI passthrough) are not Proxmox NICs.
  nics = {
    for name, s in local.vm_systems : name => [
      for i in try(s.interfaces, []) : merge(
        { ip_address = try(i.ip_address, null), vlan_id = local.vlans[i.vlan].id },
        try(i.ip_address, null) == null ? { gateway = null, prefix = null } : {
          for k, val in one([
            for sn in local.subnets[i.vlan] : sn
            if cidrhost(sn.cidr, 0) == cidrhost("${i.ip_address}/${sn.prefix}", 0)
          ]) : k => val if contains(["gateway", "prefix"], k)
        }
      ) if try(i.vlan, null) != null
    ]
  }

  dns = merge(local.site.dns, try(local.cluster.dns, {}))

  vms = {
    for name, s in local.vm_systems : name => {
      bridge        = local.cluster.bridge
      cicustom      = local.cluster.cicustom
      cores         = s.resources.cpu
      description   = try(s.description, "")
      disk_gb       = s.resources.storage_gb
      memory_mb     = s.resources.ram_gb * 1024
      name          = name
      nameservers   = tolist(local.dns.nameservers)
      nics          = tolist(local.nics[name])
      node          = local.cluster.nodes[s.host]
      search_domain = local.dns.search_domain
      storage       = local.cluster.storage
      template      = try(local.overrides[name].template, local.cluster.template)
      # Stable without bookkeeping: the first addressed NIC's VLAN and last octet, so adding a VM
      # never renumbers another. A VM with no address needs a vmid override in site.yml.
      vmid = try(local.overrides[name].vmid, try(
        local.cluster.vmid_base + 1000 * local.addressed[name][0].vlan_id +
        tonumber(split(".", local.addressed[name][0].ip_address)[3]),
        null
      ))
    }
  }

  addressed = { for name, nics in local.nics : name => [for n in nics : n if n.ip_address != null] }
}
