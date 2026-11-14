resource "docker_network" "dns_net" {
  name   = "dns_net"
  driver = "bridge"

  ipam_config {
    subnet = "172.16.3.0/24"
  }
}
