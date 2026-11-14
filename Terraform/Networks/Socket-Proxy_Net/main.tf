resource "docker_network" "socket-proxy_net" {
  name   = "socket-proxy_net"
  driver = "bridge"

  ipam_config {
    subnet = "172.16.2.0/24"
  }
}
