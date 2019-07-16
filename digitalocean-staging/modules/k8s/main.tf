
variable "acme_email" {
  description = "Admin e-mail for Let's Encrypt"
  type        = "string"
}
variable "do_token" {}
variable "domain_name" {
  description = "Root domain name for the stack"
  type        = "string"
}

################################################################################

resource "digitalocean_kubernetes_cluster" "staging_3bwins" {
  name    = "staging-3bwins"
  region  = "sgp1"
  version = "1.14.3-do.0"
  tags    = ["staging"]

  node_pool {
    name       = "staging-node-pool"
    size       = "s-2vcpu-2gb"
    node_count = 3
  }
}

provider "kubernetes" {
  host                   = "${digitalocean_kubernetes_cluster.staging_3bwins.endpoint}"
  client_certificate     = "${base64decode(digitalocean_kubernetes_cluster.staging_3bwins.kube_config.0.client_certificate)}"
  client_key             = "${base64decode(digitalocean_kubernetes_cluster.staging_3bwins.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(digitalocean_kubernetes_cluster.staging_3bwins.kube_config.0.cluster_ca_certificate)}"
}

################################################################################

module "helm" {
  source = "./helm"

  host            = "${digitalocean_kubernetes_cluster.staging_3bwins.endpoint}"
  client_cert     = "${base64decode(digitalocean_kubernetes_cluster.staging_3bwins.kube_config.0.client_certificate)}"
  client_key      = "${base64decode(digitalocean_kubernetes_cluster.staging_3bwins.kube_config.0.client_key)}"
  cluster_ca_cert = "${base64decode(digitalocean_kubernetes_cluster.staging_3bwins.kube_config.0.cluster_ca_certificate)}"
}

module "traefik_ingress_controller" {
  source = "./traefik-ingress-controller"

  acme_email  = "${var.acme_email}"
  do_token    = "${var.do_token}"
  domain_name = "${var.domain_name}"
  hostname    = "${digitalocean_kubernetes_cluster.staging_3bwins.endpoint}"
}

module "kubernetes_dashboard" {
  source = "./kubernetes-dashboard"

  domain_name = "${var.domain_name}"
}



# resource "kubernetes_namespace" "app_staging" {
#   metadata {
#     annotations = {
#       name = "app-staging"
#     }
#     labels = {
#       profile = "staging"
#     }
#     name = "app-staging"
#   }
# }
# module "deployments" {
#   source    = "./deployments"
#   namespace = "${kubernetes_namespace.app_staging.metadata.0.name}"
# }
