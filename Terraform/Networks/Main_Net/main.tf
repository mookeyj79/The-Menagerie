resource "docker_network" "main_net" {
  name   = "main_net"
  driver = "bridge"

  ipam_config {
    subnet = "172.16.1.0/24"
  }
}
