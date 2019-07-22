variable "acme_email" {}
variable "domain_name" {}
variable "do_token" {}
variable "hostname" {}
variable "tiller_secret_name" {}
variable "consul_endpoint" {}
variable "replicas" {
  default = 2
}

# Traefik helm chart.
data "template_file" "traefik_values" {
  template = "${file("${path.module}/traefik-values.yaml")}"
  vars = {
    do_token    = "${var.do_token}"
    domain_name = "${var.domain_name}"
    acme_email  = "${var.acme_email}"
    replicas    = "${var.replicas}"
    hostname    = "${var.hostname}"
    consul_endpoint = "${var.consul_endpoint}"
  }
}

resource "helm_release" "traefik" {
  chart         = "stable/traefik"
  force_update  = true
  name          = "traefik"
  namespace     = "kube-system"
  recreate_pods = true
  reuse_values  = true

  values = ["${data.template_file.traefik_values.rendered}"]
}
