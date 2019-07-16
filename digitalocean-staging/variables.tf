variable "do_token" {
  default = "$DO_TOKEN"
}

variable "ssh_pub_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "domain_name" {
  description = "Root domain name for the stack"
  default     = "staging.3bwins.com"
}

variable "acme_email" {
  default = "arch18.3bb@gmail.com"
}
