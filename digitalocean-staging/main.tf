terraform {
  required_version = "~> 0.12.3"
  backend "local" {}
}

provider "digitalocean" {
  token = "${var.do_token}"
}

module "k8s" {
  source      = "./modules/k8s"
  acme_email  = "${var.acme_email}"
  domain_name = "${var.domain_name}"
  do_token    = "${var.do_token}"
}

module "networking" {
  source              = "./modules/networking"
  domain_name         = "${var.domain_name}"
  cluster_master_ipv4 = "${module.k8s.cluster_master_ipv4}"
}

module "security" {
  source = "./modules/security"

  ssh_key_name = "${var.acme_email}"
  ssh_pub_key  = "${var.ssh_pub_key}"
}


