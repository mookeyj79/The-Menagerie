resource "docker_image" "adguard" {
  name = "adguard/adguardhome"
}

resource "docker_container" "adguard" {
  name          = "adguard"
  image         = docker_image.adguard.image_id
  hostname      = "adguard"
  restart       = "unless-stopped"
  user          = "2000:989"

  security_opts = [
    "no-new-privileges:true"
  ]

  healthcheck {
    test = ["CMD-SHELL", "netstat -lun | grep -q ':53 '"]
    interval     = "30s"
    timeout      = "5s"
    retries      = 3
    start_period = "20s"
  }

  networks_advanced {
    name = "dns_net"
    ipv4_address = "172.16.3.3"
  }

  ports {
    internal = 53
    external = 53
    protocol = "udp"
  }

  ports {
    internal = 853
    external = 853
    protocol = "tcp"
  }

  ports {
    internal = 3000
    external = 3000
    protocol = "tcp"
  }

  volumes {
    host_path      = "${var.apps_dir}/adguard/data"
    container_path = "/opt/adguardhome/work"
  }

  volumes {
    host_path      = "${var.apps_dir}/adguard/certs"
    container_path = "/opt/adguardhome/certs"
    read_only      = true
  }

  volumes {
    host_path      = "${var.apps_dir}/adguard/config"
    container_path = "/opt/adguardhome/conf"
  }
}
