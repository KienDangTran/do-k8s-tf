variable "domain_name" {}

variable "tiller_secret_name" {}

# Consul helm chart.
data "template_file" "consul_values" {
  template = "${file("${path.module}/consul-values.yaml")}"
  vars = {
    domain_name = "${var.domain_name}"
  }
}

resource "helm_release" "consul" {
  chart         = "stable/consul"
  force_update  = true
  name          = "consul"
  namespace     = "kube-system"
  recreate_pods = true
  reuse_values  = true

  values = ["${data.template_file.consul_values.rendered}"]
}

output "consul_endpoint" {
  value = "consul:8500"
}
