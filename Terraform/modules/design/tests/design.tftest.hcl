# Provider-free tests for the design module: fixture YAML in, VM objects out.

variables {
  site_file     = "./tests/fixtures/site.yml"
  structure_dir = "./tests/fixtures"
}

run "selects_live_vms_on_the_cluster" {
  command = plan

  variables {
    cluster = "pve-a"
  }

  assert {
    condition     = sort(keys(output.vms)) == tolist(["vm1", "vm2"])
    error_message = "Expected vm1 and vm2 (vm3 is on pve-b, vm4 is decommissioned, cloud1 has no host)."
  }
}

run "builds_nics_from_interfaces_and_vlans" {
  command = plan

  variables {
    cluster = "pve-a"
  }

  # vm1: gateway by named interface; storage VLAN has no gateway; tailscale0 has no VLAN, so no NIC.
  assert {
    condition = output.vms["vm1"].nics == tolist([
      { gateway = "198.51.100.1", ip_address = "198.51.100.5", prefix = 26, vlan_id = 10 },
      { gateway = null, ip_address = "192.0.2.3", prefix = 28, vlan_id = 30 },
    ])
    error_message = "vm1 NICs wrong: ${jsonencode(output.vms["vm1"].nics)}"
  }

  # vm2: address in beta's second subnet, whose gateway (rt2) has a single interface;
  # eth1 has a VLAN but no address, so it gets a NIC with no IP config.
  assert {
    condition = output.vms["vm2"].nics == tolist([
      { gateway = "203.0.113.17", ip_address = "203.0.113.20", prefix = 28, vlan_id = 20 },
      { gateway = null, ip_address = null, prefix = null, vlan_id = 10 },
    ])
    error_message = "vm2 NICs wrong: ${jsonencode(output.vms["vm2"].nics)}"
  }
}

run "places_vms_on_nodes_with_stable_vmids" {
  command = plan

  variables {
    cluster = "pve-a"
  }

  assert {
    condition     = output.vms["vm1"].node == "node-1" && output.vms["vm2"].node == "node-2"
    error_message = "Node comes from site.yml's nodes map, keyed by the system's host (a host or the group)."
  }

  # vm1 has no override: 100000 + 1000 * 10 (VLAN) + 5 (last octet).
  assert {
    condition     = output.vms["vm1"].vmid == 110005
    error_message = "vm1 vmid: ${output.vms["vm1"].vmid}"
  }

  assert {
    condition     = output.vms["vm2"].vmid == 4242
    error_message = "vm2 vmid should be the site.yml override: ${output.vms["vm2"].vmid}"
  }
}

run "carries_resources_and_site_settings" {
  command = plan

  variables {
    cluster = "pve-a"
  }

  assert {
    condition = (
      output.vms["vm1"].cores == 4 && output.vms["vm1"].memory_mb == 8192 && output.vms["vm1"].disk_gb == 100
    )
    error_message = "vm1 resources come from systems.yml (RAM in MiB)."
  }

  assert {
    condition = (
      output.vms["vm1"].template == "debian-cloud" && output.vms["vm2"].template == "special-template" &&
      output.vms["vm1"].storage == "local-lvm" && output.vms["vm1"].bridge == "vmbr0" &&
      output.vms["vm1"].cicustom == "vendor=local:snippets/ci.yaml" &&
      output.vms["vm1"].description == "First VM" && output.vms["vm1"].name == "vm1"
    )
    error_message = "Template (with override), storage, bridge, cicustom or description wrong."
  }

  assert {
    condition = (
      output.vms["vm1"].nameservers == tolist(["192.0.2.53"]) && output.vms["vm1"].search_domain == "example.lan"
    )
    error_message = "DNS settings come from site.yml's top-level dns block."
  }
}

run "cluster_dns_overrides_the_default" {
  command = plan

  variables {
    cluster = "pve-b"
  }

  assert {
    condition = (
      sort(keys(output.vms)) == tolist(["vm3"]) && output.vms["vm3"].node == "node-b" &&
      output.vms["vm3"].vmid == 10009 && output.vms["vm3"].bridge == "vmbr1" &&
      output.vms["vm3"].nameservers == tolist(["198.51.100.53"]) &&
      output.vms["vm3"].search_domain == "example.lan"
    )
    error_message = "pve-b: ${jsonencode(output.vms)}"
  }
}

run "exposes_cluster_connection_settings" {
  command = plan

  variables {
    cluster = "pve-b"
  }

  assert {
    condition = (
      output.proxmox.api_url == "https://192.0.2.11:8006" && output.proxmox.tls_insecure == false &&
      output.proxmox.token_path == "secret/proxmox/pve-b" &&
      output.openbao_address == "https://192.0.2.200:8200"
    )
    error_message = "Connection settings: ${jsonencode(output.proxmox)} ${output.openbao_address}"
  }
}

run "fails_when_a_gateway_interface_is_ambiguous" {
  command = plan

  variables {
    cluster       = "pve-a"
    structure_dir = "./tests/fixtures/ambiguous_gateway"
  }

  expect_failures = [output.vms]
}
