provider "digitalocean" {
  token = var.do_token
}

provider "aws" {
  region = var.aws_region
}
