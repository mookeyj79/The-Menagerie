resource "proxmox_vm_qemu" "seeder1" {
  agent              = 1
  automatic_reboot   = true
  balloon            = 1024
  bios               = "seabios"
  boot               = "order=scsi0"
  cicustom           = "vendor=local:snippets/cloudinit-default.yaml"
  ciupgrade          = false
  ciuser             = "root"
  clone              = "debian-cloud"
  description        = "Seeding Server (Managed by Terraform)"
  full_clone         = true
  ipconfig0          = "ip=192.168.4.2/26,gw=192.168.4.1"
  ipconfig1          = "ip=192.168.5.2/29"
  memory             = 6144
  name               = "Seeder1"
  nameserver         = "192.168.5.6,1.1.1.1,9.9.9.9"
  os_type            = "cloud-init"
  qemu_os            = "l26"
  scsihw             = "virtio-scsi-single"
  searchdomain       = "mikewashere.lan"
  skip_ipv6          = true
  start_at_node_boot = true
  tags               = "seeder,terraform"
  target_node        = var.proxmox_pve_node
  vm_state           = "running"
  vmid               = 100

  cpu {
    cores   = 3
    type    = "x86-64-v2-AES"
    sockets = 1
  }

  disks {
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }

    scsi {
      scsi0 {
        disk {
          size    = "64G"
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    bridge = "vmbr0"
    id     = 0
    model  = "virtio"
    tag    = 4
  }

network {
    bridge = "vmbr0"
    id     = 1
    model  = "virtio"
    tag    = 5
  }

  serial {
    id   = 0
    type = "socket"
  }

    startup_shutdown {
    order = 2
    shutdown_timeout = 60
    startup_delay = 60
  }

  vga {
    type = "serial0"
  }
}
