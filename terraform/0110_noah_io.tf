# Zone
variable "domain_noahh_io_name" {
  type = "string"
  description = "Name of noahh.io domain"
  default = "noahh.io"
}

resource "aws_route53_zone" "noahh-io" {
  name = "${var.domain_noahh_io_name}"
}

# Records
# ... Personal website
resource "aws_route53_record" "noahh-io-personal-website-wildcard" {
  zone_id = "${aws_route53_zone.noahh-io.id}"
  name = "*.${aws_route53_zone.noahh-io.name}"
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.personal-website.domain_name}"
    zone_id = "${aws_cloudfront_distribution.personal-website.hosted_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "noahh-io-personal-website-apex" {
  zone_id = "${aws_route53_zone.noahh-io.id}"
  name = "${aws_route53_zone.noahh-io.name}"
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.personal-website.domain_name}"
    zone_id = "${aws_cloudfront_distribution.personal-website.hosted_zone_id}"
    evaluate_target_health = true
  }
}

# ... Apex TXT
resource "aws_route53_record" "noahh-io-apex-txt" {
  zone_id = "${aws_route53_zone.noahh-io.id}"
  type = "TXT"
  ttl = "1800"
  name = "${aws_route53_zone.noahh-io.name}"
  records = [
    # Protonmail veritifcation
    "protonmail-verification=22cdd158fff490e87ec1b1964e266de6935e653a",

    # Protonmail SPF
    "v=spf1 include:_spf.protonmail.ch mx ~all"
  ]
}

# ... Keybase
resource "aws_route53_record" "noahh-io-keybase" {
  zone_id = "${aws_route53_zone.noahh-io.id}"
  type = "TXT"
  ttl = "60" # seconds
  name = "_keybase"
  records = [
    "keybase-site-verification=qLC-aj3hDn591K3qx2EX-aiZTb09QLlk2IY4BmuOBmI"
  ]
}

# ... Protonmail
resource "aws_route53_record" "noahh-io-protonmail-mx" {
  zone_id = "${aws_route53_zone.noahh-io.id}"
  type = "MX"
  ttl = "14400"
  name = "${aws_route53_zone.noahh-io.name}"
  records = [
    "10 mail.protonmail.ch.",
    "20 mailsec.protonmail.ch"
  ]
}

resource "aws_route53_record" "noahh-io-protonmail-dkim" {
  zone_id = "${aws_route53_zone.noahh-io.id}"
  type = "TXT"
  ttl = "3600"
  name = "protonmail._domainkey.${aws_route53_zone.noahh-io.name}"
  records = [
    "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDNDdmnmb+9FGSMvNNzW6S1ZgwLl9BT7FTqvk3/HmvQHxOPir3f+m14BzOEE2kON2GW7pmERxY/+RUGghGj/WD+Uj3JP+RQY/cmFdZ+pjiVZZe3759uFaj3pHnnf9sjXjp5rWunMThuA+buS1pBxRTMVIytWVHuSvEdl0pNOiEaZQIDAQAB"
  ]
}

resource "aws_route53_record" "noahh-io-protonmail-dmarc" {
  zone_id = "${aws_route53_zone.noahh-io.id}"
  type = "TXT"
  ttl = "3600"
  name = "_dmarc.${aws_route53_zone.noahh-io.name}"
  records = [
    "v=DMARC1; p=none; rua=mailto:contact@noahh.io"
  ]
}
