resource "docker_image" "unbound" {
  name = "mvance/unbound:latest"
}

resource "docker_container" "unbound" {
  name          = "unbound"
  image         = docker_image.unbound.image_id
  hostname      = "unbound"
  restart       = "unless-stopped"

  security_opts = [
    "no-new-privileges:true"
  ]

  healthcheck {
    test = ["CMD", "drill", "cloudflare.com", "@127.0.0.1", "-p", "5335"]
    interval     = "30s"
    timeout      = "5s"
    retries      = 3
    start_period = "20s"
  }

  networks_advanced {
    name = "dns_net"
    ipv4_address = "172.16.3.2"
  }

  volumes {
    host_path      = "${var.apps_dir}/unbound/config/unbound.conf"
    container_path = "/opt/unbound/etc/unbound/unbound.conf"
    read_only      = true
  }
}
