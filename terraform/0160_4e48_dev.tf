# Zone
variable "domain_4e48_dev_name" {
  type = string
  description = "Name of 4e48.dev domain"
  default = "4e48.dev"
}

variable "minecraft_server_ipv4" {
  type = string
  description = "IPv4 address of minecraft server"
  default = "34.238.12.88"
}

resource "aws_route53_zone" "domain-4e48-dev" {
  name = var.domain_4e48_dev_name
}

# Records
resource "aws_route53_record" "record-4e48-dev-personal-website-wildcard" {
  zone_id = aws_route53_zone.domain-4e48-dev.id
  name = "*.${aws_route53_zone.domain-4e48-dev.name}"
  type = "A"

  alias {
    name = aws_cloudfront_distribution.personal-website.domain_name
    zone_id = aws_cloudfront_distribution.personal-website.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "record-4e48-dev-personal-website-apex" {
  zone_id = aws_route53_zone.domain-4e48-dev.id
  name = aws_route53_zone.domain-4e48-dev.name
  type = "A"

  alias {
    name = aws_cloudfront_distribution.personal-website.domain_name
    zone_id = aws_cloudfront_distribution.personal-website.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "record-4e48-dev-minecraft" {
  zone_id = aws_route53_zone.domain-4e48-dev.id
  name = "minecraft.${aws_route53_zone.domain-4e48-dev.name}"
  type = "A"
  records = [
    var.minecraft_server_ipv4
  ]
}
