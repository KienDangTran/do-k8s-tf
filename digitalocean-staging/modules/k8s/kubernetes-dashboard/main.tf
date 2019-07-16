variable "domain_name" {
  description = "Root domain name for the stack"
  type        = "string"
}

################################################################################

data "template_file" "kubernetes_dashboard_values" {
  template = "${file("${path.module}/kubernetes-dashboard-values.yaml")}"

  vars = {
    domain_name = "${var.domain_name}"
  }
}

resource "helm_release" "kubernetes_dashboard" {
  name          = "kubernetes-dashboard"
  chart         = "stable/kubernetes-dashboard"
  force_update  = true
  namespace     = "kube-system"
  recreate_pods = true
  reuse_values  = true

  values = ["${data.template_file.kubernetes_dashboard_values.rendered}"]
}
