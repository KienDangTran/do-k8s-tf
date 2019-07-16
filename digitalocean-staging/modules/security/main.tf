variable "ssh_pub_key" {}
variable "ssh_key_name" {}

# resource "digitalocean_certificate" "letsencrypt_cert_3bwins_net" {
#   name    = "letsencrypt-cert-3bwins-net"
#   type    = "lets_encrypt"
#   domains = ["3bwins.net", "staging.3bwins.net"]
# }

resource "digitalocean_ssh_key" "arch18_ssh_key" {
  name       = "${var.ssh_key_name}"
  public_key = "${file("${var.ssh_pub_key}")}"
}