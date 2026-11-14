resource "docker_image" "vault" {
  name = "hashicorp/vault:latest"
}

resource "docker_container" "vault" {
  hostname      = "vault"
  image         = docker_image.vault.image_id
  name          = "vault"
  restart       = "unless-stopped"
  user          = "2008:989"

  command = [
    "vault",
    "server",
    "--config=/vault/config/vault.hcl"
  ]

  capabilities {
    add = ["IPC_LOCK"]
  }

  env = [
    "AWS_PROFILE=vault",
    "AWS_SDK_LOAD_CONFIG=1",
    "AWS_SHARED_CREDENTIALS_FILE=/home/vault/.aws/credentials",
    "AWS_CONFIG_FILE=/home/vault/.aws/config",
    "HOME=/home/vault",
    "SKIP_CHOWN=true",
    "SKIP_SETCAP=true"
  ]

  healthcheck {
    test         = ["CMD", "vault", "status", "-address=http://127.0.0.1:8200"]
    interval     = "30s"
    timeout      = "5s"
    retries      = 3
    start_period = "10s"
  }

  networks_advanced {
    name = "main_net"
  }

  ports {
    internal = 8200
    external = 8200
    protocol = "tcp"
  }

  security_opts = [
    "no-new-privileges:true"
  ]

  volumes {
    host_path      = "${var.apps_dir}/vault/certs"
    container_path = "/vault/certs"
  }

  volumes {
    host_path      = "${var.apps_dir}/vault/config/vault.hcl"
    container_path = "/vault/config/vault.hcl"
    read_only      = true
  }

  volumes {
    host_path      = "${var.apps_dir}/vault/data"
    container_path = "/vault/file"
  }

  volumes {
    host_path      = "${var.apps_dir}/vault/logs"
    container_path = "/vault/logs"
  }

  volumes {
    host_path      = "${var.apps_dir}/vault/logs"
    container_path = "/vault/logs"
  }

  volumes {
    host_path      = "${var.apps_dir}/vault/logs"
    container_path = "/vault/logs"
  }

  volumes {
    host_path      = "${var.apps_dir}/vault/secrets/aws_config"
    container_path = "/home/vault/.aws/config"
    read_only      = true
  }

  volumes {
    host_path      = "${var.apps_dir}/vault/secrets/aws_credentials"
    container_path = "/home/vault/.aws/credentials"
    read_only      = true
  }
}
