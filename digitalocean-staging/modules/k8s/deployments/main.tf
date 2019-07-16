
variable "namespace" {}

################################################################################

module "postgres" {
  source    = "./postgres"
  namespace = "${var.namespace}"
}
