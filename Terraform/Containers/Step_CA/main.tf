resource "docker_image" "step-ca" {
  name = "smallstep/step-ca:latest"
}

resource "docker_container" "step-ca" {
  hostname      = "step-ca"
  image         = docker_image.step-ca.image_id
  name          = "step-ca"
  restart       = "unless-stopped"
  user          = "2005:989"

  command = [
    "/usr/local/bin/step-ca",
    "/home/step/config/ca.json",
    "--password-file",
    "/home/step/secrets/password"
  ]

  env = [
    "STEPPATH=/home/step"
  ]

  healthcheck {
    test         = ["CMD", "curl", "-fk", "https://localhost/health"]
    interval     = "30s"
    timeout      = "5s"
    retries      = 3
    start_period = "10s"
  }

  networks_advanced {
    name = "main_net"
  }

  ports {
    internal = 443
    external = 443
    protocol = "tcp"
  }

  security_opts = [
    "no-new-privileges:true"
  ]

  volumes {
    host_path      = "${var.apps_dir}/step-ca/certs"
    container_path = "/home/step/certs"
  }

  volumes {
    host_path      = "${var.apps_dir}/step-ca/config"
    container_path = "/home/step/config"
  }

  volumes {
    host_path      = "${var.apps_dir}/step-ca/data"
    container_path = "/home/step/db"
  }

  volumes {
    host_path      = "${var.apps_dir}/step-ca/secrets"
    container_path = "/home/step/secrets"
  }
}
