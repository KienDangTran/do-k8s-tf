variable "host" {}
variable "client_cert" {}
variable "client_key" {}
variable "cluster_ca_cert" {}

################################################################################

resource "kubernetes_service_account" "tiller" {
  automount_service_account_token = true

  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
  depends_on = ["kubernetes_service_account.tiller"]

  metadata {
    name = "tiller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.tiller.metadata.0.name}"
    namespace = "${kubernetes_service_account.tiller.metadata.0.namespace}"
  }
}

provider "helm" {
  install_tiller  = true
  service_account = "tiller"

  kubernetes {
    host                   = "${var.host}"
    client_certificate     = "${var.client_cert}"
    client_key             = "${var.client_key}"
    cluster_ca_certificate = "${var.cluster_ca_cert}"
  }
}
