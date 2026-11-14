resource "proxmox_vm_qemu" "db1" {
  agent              = 1
  automatic_reboot   = true
  balloon            = 1024
  bios               = "seabios"
  boot               = "order=scsi0"
  cicustom           = "vendor=local:snippets/cloudinit-default.yaml"
  ciupgrade          = false
  ciuser             = "root"
  clone              = "debian-cloud"
  description        = "Database Server (Managed by Terraform)"
  full_clone         = true
  ipconfig0          = "ip=192.168.16.4/26,gw=192.168.16.1"
  memory             = 24576
  name               = "DB1"
  nameserver         = "192.168.5.6"
  start_at_node_boot = true
  os_type            = "cloud-init"
  qemu_os            = "l26"
  scsihw             = "virtio-scsi-single"
  searchdomain       = "mikewashere.lan"
  skip_ipv6          = true
  tags               = "database,terraform"
  target_node        = var.proxmox_pve_node
  vm_state           = "running"
  vmid               = 101

  cpu {
    cores   = 4
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
          size    = "512G"
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    bridge = "vmbr0"
    id     = 0
    model  = "virtio"
    tag    = 16
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
