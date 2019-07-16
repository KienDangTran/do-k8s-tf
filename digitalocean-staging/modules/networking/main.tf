variable "domain_name" {
  description = "Root domain name for the stack"
}

variable "cluster_master_ipv4" {
  description = "The public IPv4 address of the Kubernetes master node"
}

################################################################################
resource "digitalocean_domain" "default_domain" {
  name = "${var.domain_name}"
}

# DNS records
resource "digitalocean_record" "main_ipv4" {
  domain = "${digitalocean_domain.default_domain.name}"
  type   = "A"
  name   = "@"
  value  = "${var.cluster_master_ipv4}"
}
resource "digitalocean_record" "san_ipv4" {
  domain = "${digitalocean_domain.default_domain.name}"
  type   = "A"
  name   = "*"
  value  = "${var.cluster_master_ipv4}"
}