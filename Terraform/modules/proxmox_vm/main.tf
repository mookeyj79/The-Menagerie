locals {
  # Cloud-init ipconfigN per NIC. A NIC with no address gets no IP config; a NIC on a subnet
  # with no gateway (such as an unrouted storage VLAN) gets an address only.
  ipconfig = [
    for n in var.vm.nics : n.ip_address == null ? null : join(",", compact([
      "ip=${n.ip_address}/${n.prefix}",
      n.gateway == null ? "" : "gw=${n.gateway}",
    ]))
  ]
}

resource "proxmox_vm_qemu" "this" {
  agent              = 1
  automatic_reboot   = true
  bios               = "seabios"
  boot               = "order=scsi0"
  cicustom           = var.vm.cicustom
  ciupgrade          = false
  clone              = var.vm.template
  description        = "${var.vm.description} (managed by Terraform)"
  full_clone         = true
  ipconfig0          = try(local.ipconfig[0], null)
  ipconfig1          = try(local.ipconfig[1], null)
  ipconfig2          = try(local.ipconfig[2], null)
  ipconfig3          = try(local.ipconfig[3], null)
  ipconfig4          = try(local.ipconfig[4], null)
  ipconfig5          = try(local.ipconfig[5], null)
  ipconfig6          = try(local.ipconfig[6], null)
  ipconfig7          = try(local.ipconfig[7], null)
  ipconfig8          = try(local.ipconfig[8], null)
  ipconfig9          = try(local.ipconfig[9], null)
  ipconfig10         = try(local.ipconfig[10], null)
  ipconfig11         = try(local.ipconfig[11], null)
  ipconfig12         = try(local.ipconfig[12], null)
  ipconfig13         = try(local.ipconfig[13], null)
  ipconfig14         = try(local.ipconfig[14], null)
  ipconfig15         = try(local.ipconfig[15], null)
  memory             = var.vm.memory_mb
  name               = var.vm.name
  nameserver         = join(" ", var.vm.nameservers)
  os_type            = "cloud-init"
  qemu_os            = "l26"
  scsihw             = "virtio-scsi-single"
  searchdomain       = var.vm.search_domain
  skip_ipv6          = true
  start_at_node_boot = true
  tags               = "terraform"
  target_node        = var.vm.node
  vm_state           = "running"
  vmid               = var.vm.vmid

  cpu {
    cores   = var.vm.cores
    sockets = 1
    type    = "x86-64-v2-AES"
  }

  disks {
    ide {
      ide2 {
        cloudinit {
          storage = var.vm.storage
        }
      }
    }

    scsi {
      scsi0 {
        disk {
          size    = "${var.vm.disk_gb}G"
          storage = var.vm.storage
        }
      }
    }
  }

  dynamic "network" {
    for_each = var.vm.nics

    content {
      bridge = var.vm.bridge
      id     = network.key
      model  = "virtio"
      tag    = network.value.vlan_id
    }
  }

  serial {
    id   = 0
    type = "socket"
  }

  vga {
    type = "serial0"
  }
}
