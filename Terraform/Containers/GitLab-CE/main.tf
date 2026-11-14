resource "docker_image" "gitlab-ce" {
  name = "gitlab/gitlab-ce:rc"
}

resource "docker_container" "gitlab-ce" {
  name          = "gitlab-ce"
  image         = docker_image.gitlab-ce.image_id
  hostname      = "gitlab-ce"
  restart       = "unless-stopped"
  shm_size      = 512
  # user          = "1000:989"

  security_opts = [
    "no-new-privileges:true"
  ]

  env = [
    "TZ=Etc/UTC"
  ]

  healthcheck {
    test         = ["CMD-SHELL", "gitlab-ctl status || exit 1"]
    interval     = "30s"
    timeout      = "10s"
    retries      = 3
    start_period = "600s"
  }

  networks_advanced {
    name = "main_net"
  }

  ports {
    internal = 80
    external = 80
    protocol = "tcp"
  }

  ports {
    internal = 443
    external = 443
    protocol = "tcp"
  }

  ports {
    internal = 22
    external = 2222
    protocol = "tcp"
  }

  sysctls = {
    "net.core.somaxconn" = "1024"
  }

  volumes {
    host_path      = "${var.apps_dir}/gitlab-ce/data"
    container_path = "/var/opt/gitlab"
  }

  volumes {
    host_path      = "${var.apps_dir}/gitlab-ce/logs"
    container_path = "/var/log/gitlab"
  }

  volumes {
    host_path      = "${var.apps_dir}/gitlab-ce/config"
    container_path = "/etc/gitlab"
  }

  volumes {
    host_path      = "${var.apps_dir}/gitlab-ce/config/gitlab.rb"
    container_path = "/etc/gitlab/gitlab.rb"
    read_only      = true
  }

  volumes {
    host_path      = "${var.secrets_dir}/gitlab-ce/postgresql_password"
    container_path = "/var/secrets/postgresql_password"
    read_only      = true
  }

  volumes {
    host_path      = "${var.secrets_dir}/gitlab-ce/postgresql_username"
    container_path = "/var/secrets/postgresql_username"
    read_only      = true
  }

  volumes {
    host_path      = "${var.secrets_dir}/gitlab-ce/redis_password"
    container_path = "/var/secrets/redis_password"
    read_only      = true
  }

  volumes {
    host_path      = "${var.secrets_dir}/gitlab-ce/redis_username"
    container_path = "/var/secrets/redis_username"
    read_only      = true
  }
}
