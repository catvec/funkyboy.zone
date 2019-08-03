# Variables
variable "do_token" {
  type = "string"
  description = "Digital Ocean API token"
}

# Setup provider
provider "digitalocean" {
  token = "${var.do_token}"
  version = 4
}
