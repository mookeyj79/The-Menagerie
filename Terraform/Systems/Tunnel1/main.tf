resource "proxmox_vm_qemu" "tunnel1" {
  agent              = 1
  automatic_reboot   = true
  balloon            = 1024
  bios               = "seabios"
  boot               = "order=scsi0"
  cicustom           = "vendor=local:snippets/cloudinit-default.yaml"
  ciupgrade          = false
  ciuser             = "root"
  clone              = "debian-cloud"
  description        = "Tunnel Management Server (Managed by Terraform)"
  full_clone         = true
  ipconfig0          = "ip=192.168.4.4/26,gw=192.168.4.1"
  memory             = 2048
  name               = "Tunnel1"
  nameserver         = "192.168.5.6"
  os_type            = "cloud-init"
  qemu_os            = "l26"
  scsihw             = "virtio-scsi-single"
  searchdomain       = "mikewashere.lan"
  skip_ipv6          = true
  start_at_node_boot = true
  tags               = "tunnel,terraform"
  target_node        = var.proxmox_pve_node
  vm_state           = "running"
  vmid               = 101

  cpu {
    cores   = 1
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
          size    = "16G"
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
