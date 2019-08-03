# Zone
variable "domain_spode_space_name" {
  type = "string"
  description = "Name of spode.space domain"
  default = "spode.space"
}

resource "aws_route53_zone" "domain-spode-space" {
  name = "${var.domain_spode_space_name}"
}
