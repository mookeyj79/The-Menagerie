resource "docker_image" "tailscale" {
  name = "tailscale/tailscale:stable"
}

resource "docker_container" "tailscale" {
  hostname      = "tailscale"
  image         = docker_image.tailscale.image_id
  name          = "tailscale"
  restart       = "unless-stopped"
  privileged    = true
  network_mode  = "host"

  capabilities {
    add = ["NET_ADMIN", "SYS_MODULE"]
  }

  command = ["/start-tailscale.sh"]

  healthcheck {
    test         = ["CMD", "tailscale", "status", "--json"]
    interval     = "30s"
    timeout      = "5s"
    retries      = 3
    start_period = "10s"
  }

  security_opts = [
    "no-new-privileges:true"
  ]

  volumes {
    host_path      = "${var.apps_dir}/tailscale/data"
    container_path = "/var/lib/tailscale"
  }

  volumes {
    host_path      = "${var.apps_dir}/tailscale/secrets/tailscale_authkey"
    container_path = "/run/secrets/tailscale_authkey"
    read_only      = true
  }

  volumes {
    host_path      = "${var.apps_dir}/tailscale/secrets/tailscale_hostname"
    container_path = "/run/secrets/tailscale_hostname"
    read_only      = true
  }

  volumes {
    host_path      = "${var.apps_dir}/tailscale/secrets/tailscale_routes"
    container_path = "/run/secrets/tailscale_routes"
    read_only      = true
  }

  volumes {
    host_path      = "${var.apps_dir}/tailscale/bin/start-tailscale.sh"
    container_path = "/start-tailscale.sh"
    read_only      = true
  }
}
