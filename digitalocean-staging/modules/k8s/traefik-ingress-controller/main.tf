variable "acme_email" {
  description = "Admin e-mail for Let's Encrypt"
  type        = "string"
}
variable "domain_name" {
  description = "Root domain name for the stack"
  type        = "string"
}
variable "do_token" {}
variable "hostname" {}
variable "replicas" {
  default = 2
}


################################################################################

# Consul helm chart.
resource "helm_release" "consul" {
  chart         = "stable/consul"
  force_update  = true
  name          = "consul"
  namespace     = "kube-system"
  recreate_pods = true
  reuse_values  = true
}

data "template_file" "traefik_values" {
  template = "${file("${path.module}/traefik-values.yaml")}"
  vars = {
    do_token    = "${var.do_token}"
    domain_name = "${var.domain_name}"
    acme_email  = "${var.acme_email}"
    replicas    = "${var.replicas}"
    hostname    = "${var.hostname}"
  }
}

# Traefik helm chart.
resource "helm_release" "traefik" {
  depends_on = ["helm_release.consul"]

  chart         = "stable/traefik"
  force_update  = true
  name          = "traefik"
  namespace     = "kube-system"
  recreate_pods = true
  reuse_values  = true

  values = ["${data.template_file.traefik_values.rendered}"]
}
