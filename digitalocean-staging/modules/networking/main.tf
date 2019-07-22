variable "domain_name" {
  description = "Root domain name for the stack"
}

resource "digitalocean_domain" "default_domain" {
  name = "${var.domain_name}"
}
