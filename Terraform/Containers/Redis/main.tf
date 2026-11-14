resource "docker_image" "redis" {
  name = "redis:8-alpine"
}

resource "docker_container" "redis" {
  name          = "redis"
  image         = docker_image.redis.image_id
  hostname      = "redis"
  restart       = "unless-stopped"
  user          = "2004:989"

  security_opts = [
    "no-new-privileges:true"
  ]

  command = [
    "redis-server",
    "/usr/local/etc/redis/redis.conf"
  ]

  env = [
    "SKIP_FIX_PERMS=1"
  ]

  healthcheck {
    test = var.redis_use_tls ? ["CMD-SHELL", "redis-cli --tls --cacert /certs/ca.crt -h 127.0.0.1 -p 6379 --user healthcheck -a '' PING | grep PONG"] : ["CMD-SHELL", "redis-cli -h 127.0.0.1 -p 6379 --user healthcheck -a '' PING | grep PONG"]
    interval     = "30s"
    timeout      = "5s"
    retries      = 3
    start_period = "20s"
  }

  networks_advanced {
    name = "main_net"
  }

  ports {
    internal = 6379
    external = 6379
    protocol = "tcp"
  }

  volumes {
    host_path      = "${var.apps_dir}/redis/certs"
    container_path = "/certs"
  }

  volumes {
    host_path      = "${var.apps_dir}/redis/data"
    container_path = "/data"
  }

  volumes {
    host_path      = "${var.apps_dir}/redis/logs"
    container_path = "/var/log/redis"
  }

  volumes {
    host_path      = "${var.apps_dir}/redis/config/redis.conf"
    container_path = "/usr/local/etc/redis/redis.conf"
    read_only      = true
  }

  volumes {
    host_path      = "${var.apps_dir}/redis/config/redis.acl"
    container_path = "/usr/local/etc/redis/redis.acl"
    read_only      = true
  }
}
