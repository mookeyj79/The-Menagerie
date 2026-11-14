resource "docker_image" "postgresql" {
  name = "postgres:18-alpine"
}

resource "docker_container" "postgresql" {
  name          = "postgresql"
  image         = docker_image.postgresql.image_id
  hostname      = "postgresql"
  restart       = "unless-stopped"
  shm_size      = 1024
  user          = "2003:989"

  security_opts = [
    "no-new-privileges:true"
  ]

  command = [
    "postgres",
    "-c", "config_file=/etc/postgresql/postgresql.conf"
  ]

  env = [
    "POSTGRES_USER=${local.postgresql_username}",
    "POSTGRES_PASSWORD=${local.postgresql_password}",
    "POSTGRES_DB=${local.postgresql_db}",
    "PGDATA=/var/lib/postgresql/18/docker",
    "TZ=UTC"
  ]

  healthcheck {
    test         = ["CMD-SHELL", "pg_isready -U ${local.postgresql_username} -d postgres || exit 1"]
    interval     = "30s"
    timeout      = "5s"
    retries      = 3
    start_period = "20s"
  }

  networks_advanced {
    name = "main_net"
  }

  ports {
    internal = 5432
    external = 5432
    protocol = "tcp"
  }

  volumes {
    host_path      = "/opt/apps/postgresql/data"
    container_path = "/var/lib/postgresql"
  }

  volumes {
    host_path      = "/opt/apps/postgresql/logs"
    container_path = "/var/log/postgresql"
  }

  volumes {
    host_path      = "/opt/apps/postgresql/config/postgresql.conf"
    container_path = "/etc/postgresql/postgresql.conf"
    read_only      = true
  }

  volumes {
    host_path      = "/opt/apps/postgresql/config/pg_hba.conf"
    container_path = "/etc/postgresql/pg_hba.conf"
    read_only      = true
  }
}
