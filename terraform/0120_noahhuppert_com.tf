# Zone
variable "domain_noahhuppert_com_name" {
  type = string
  description = "Name of noahhuppert.com domain"
  default = "noahhuppert.com"
}

data "digitalocean_domain" "noahhuppert_com" {
  name = var.domain_noahhuppert_com_name
}

# Records
resource "digitalocean_record" "noahhuppert_com_wildcard" {
  domain = data.digitalocean_domain.noahhuppert_com.name
  type = "A"
  ttl = "60" # seconds
  name = "*"
  value = digitalocean_droplet.funkyboy_zone.ipv4_address
}

resource "digitalocean_record" "noahhuppert_com_apex" {
  domain = data.digitalocean_domain.noahhuppert_com.name
  type = "A"
  ttl = "60" # seconds
  name = "@"
  value = digitalocean_droplet.funkyboy_zone.ipv4_address
}

resource "digitalocean_record" "noahhuppert_com_protonmail_verification" {
  domain = data.digitalocean_domain.noahhuppert_com.name
  type = "TXT"
  ttl = "1800" # seconds
  name = "@"
  value = "protonmail-verification=445adbc2c30dfd5f7e79ff00b0254cc6d65b6841"
}

resource "digitalocean_record" "noahhuppert_com_protonmail_spf" {
  domain = data.digitalocean_domain.noahhuppert_com.name
  type = "TXT"
  ttl = "1800" # seconds
  name = "@"
  value = "v=spf1 include:_spf.protonmail.ch mx ~all"
}

resource "digitalocean_record" "noahhuppert_com_protonmail_keybase" {
  domain = data.digitalocean_domain.noahhuppert_com.name
  type = "TXT"
  ttl = "60" # seconds
  name = "_keybase"
  value = "keybase-site-verification=JLTh13lgHP5frw5NRtWBWquFyy2GHCaVHXhph2g6qbQ"
}

resource "digitalocean_record" "noahhuppert_com_protonmail_mx10" {
  domain = data.digitalocean_domain.noahhuppert_com.name
  type = "MX"
  ttl = "14400" # seconds
  name = "@"
  priority = 10
  value = "mail.protonmail.ch."
}

resource "digitalocean_record" "noahhuppert_com_protonmail_mx20" {
  domain = data.digitalocean_domain.noahhuppert_com.name
  type = "MX"
  ttl = "14400" # seconds
  name = "@"
  priority = 20
  value = "mailsec.protonmail.ch."
}

resource "digitalocean_record" "noahhuppert_com_protonmail_dkim" {
  domain = data.digitalocean_domain.noahhuppert_com.name
  type = "TXT"
  ttl = "3600" # seconds
  name = "protonmail._domainkey.${var.domain_noahhuppert_com_name}"
  value = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC7Z45ntjf7Ked7IKP0rGdtj5jucEIOIZaCYXkLkMX6/mGYCiO1Fz7t67LiuL82Ba5pQFghEtpLZHdI9ug+2tiH7oYr3/LrCPVSCRUDzdYZlk0C0evZhKrn7BUfNfVamF8j8THJsFcOvNjgCRFARuMQRGZj350eYRjOVeL4AfFDpwIDAQAB"
}

resource "digitalocean_record" "noahhuppert_com_protonmail_dmarc" {
  domain = data.digitalocean_domain.noahhuppert_com.name
  type = "TXT"
  ttl = "3600" # seconds
  name = "_dmarc.${var.domain_noahhuppert_com_name}"
  value = "v=DMARC1; p=none; rua=mailto:contact@noahhuppert.com"
}

# OLD
# resource "aws_route53_zone" "noahhuppert_com" {
#   name = var.domain_noahhuppert_com_name
# }

# Records
# ... Personal website
# resource "aws_route53_record" "noahhuppert_com_personal_website_wildcard" {
#   zone_id = aws_route53_zone.noahhuppert_com.id
#   name = "*.${aws_route53_zone.noahhuppert_com.name}"
#   type = "A"

#   alias {
#     name = aws_cloudfront_distribution.personal_website.domain_name
#     zone_id = aws_cloudfront_distribution.personal_website.hosted_zone_id
#     evaluate_target_health = true
#   }
# }

# resource "aws_route53_record" "noahhuppert_com_personal_website_apex" {
#   zone_id = aws_route53_zone.noahhuppert_com.id
#   name = aws_route53_zone.noahhuppert_com.name
#   type = "A"

#   alias {
#     name = aws_cloudfront_distribution.personal_website.domain_name
#     zone_id = aws_cloudfront_distribution.personal_website.hosted_zone_id
#     evaluate_target_health = true
#   }
# }

# ... Apex TXT
# resource "aws_route53_record" "noahhuppert_com_apex_txt" {
#   zone_id = aws_route53_zone.noahhuppert_com.id
#   type = "TXT"
#   ttl = "1800"
#   name = aws_route53_zone.noahhuppert_com.name
#   records = [
#     # Protonmail veritifcation
#     "protonmail-verification=445adbc2c30dfd5f7e79ff00b0254cc6d65b6841",

#     # Protonmail SPF
#     "v=spf1 include:_spf.protonmail.ch mx ~all"
#   ]
# }

# ... Keybase
# resource "aws_route53_record" "noahhuppert_com_keybase" {
#   zone_id = aws_route53_zone.noahhuppert_com.id
#   type = "TXT"
#   ttl = "60" # seconds
#   name = "_keybase"
#   records = [
#     "keybase-site-verification=JLTh13lgHP5frw5NRtWBWquFyy2GHCaVHXhph2g6qbQ"
#   ]
# }

# ... Protonmail
# resource "aws_route53_record" "noahhuppert_com_protonmail_mx" {
#   zone_id = aws_route53_zone.noahhuppert_com.id
#   type = "MX"
#   ttl = "14400"
#   name = aws_route53_zone.noahhuppert_com.name
#   records = [
#     "10 mail.protonmail.ch.",
#     "20 mailsec.protonmail.ch"
#   ]
# }

# resource "aws_route53_record" "noahhuppert_com_protonmail_dkim" {
#   zone_id = aws_route53_zone.noahhuppert_com.id
#   type = "TXT"
#   ttl = "3600"
#   name = "protonmail._domainkey.${aws_route53_zone.noahhuppert_com.name}"
#   records = [
#     "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC7Z45ntjf7Ked7IKP0rGdtj5jucEIOIZaCYXkLkMX6/mGYCiO1Fz7t67LiuL82Ba5pQFghEtpLZHdI9ug+2tiH7oYr3/LrCPVSCRUDzdYZlk0C0evZhKrn7BUfNfVamF8j8THJsFcOvNjgCRFARuMQRGZj350eYRjOVeL4AfFDpwIDAQAB"
#   ]
# }

# resource "aws_route53_record" "noahhuppert_com_protonmail_dmarc" {
#   zone_id = aws_route53_zone.noahhuppert_com.id
#   type = "TXT"
#   ttl = "3600"
#   name = "_dmarc.${aws_route53_zone.noahhuppert_com.name}"
#   records = [
#     "v=DMARC1; p=none; rua=mailto:contact@noahhuppert.com"
#   ]
# }
