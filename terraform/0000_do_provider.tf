# Setup provider
provider "digitalocean" {
	token = "${var.do_token}"
}

# Variables
variable "do_token" {
	type = "string"
	description = "Digital Ocean API token"
}
