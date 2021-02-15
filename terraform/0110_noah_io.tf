# Zone
variable "domain_noahh_io_name" {
  type = string
  description = "Name of noahh.io domain"
  default = "noahh.io"
}

data "digitalocean_domain" "noahh_io" {
  name = var.domain_noahh_io_name
}

# Records
resource "digitalocean_record" "noahh_io_wildcard" {
  domain = data.digitalocean_domain.noahh_io.name
  type = "A"
  ttl = "60" # seconds
  name = "*"
  value = digitalocean_droplet.funkyboy_zone.ipv4_address
}

resource "digitalocean_record" "noahh_io_apex" {
  domain = data.digitalocean_domain.noahh_io.name
  type = "A"
  ttl = "60" # seconds
  name = "@"
  value = digitalocean_droplet.funkyboy_zone.ipv4_address
}

resource "digitalocean_record" "noahh_io_protonmail_vertification" {
  domain = data.digitalocean_domain.noahh_io.name
  type = "TXT"
  ttl = "1800" # seconds
  name = "@"
  value = "protonmail-verification=22cdd158fff490e87ec1b1964e266de6935e653a"
}

resource "digitalocean_record" "noahh_io_protonmail_spf" {
  domain = data.digitalocean_domain.noahh_io.name
  type = "TXT"
  ttl = "1800" # seconds
  name = "@"
  value = "v=spf1 include:_spf.protonmail.ch mx ~all"
}

resource "digitalocean_record" "noahh_io_protonmail_keybase" {
  domain = data.digitalocean_domain.noahh_io.name
  type = "TXT"
  ttl = "1800" # seconds
  name = "_keybase"
  value = "keybase-site-verification=qLC-aj3hDn591K3qx2EX-aiZTb09QLlk2IY4BmuOBmI"
}

resource "digitalocean_record" "noahh_io_protonmail_mx10" {
  domain = data.digitalocean_domain.noahh_io.name
  type = "TXT"
  ttl = "1800" # seconds
  name = "@"
  priority = 10
  value = "mail.protonmail.ch."
}

resource "digitalocean_record" "noahh_io_protonmail_mx20" {
  domain = data.digitalocean_domain.noahh_io.name
  type = "TXT"
  ttl = "1800" # seconds
  name = "@"
  priority = 20
  value = "mailsec.protonmail.ch."
}

resource "digitalocean_record" "noahh_io_protonmail_dkim" {
  domain = data.digitalocean_domain.noahh_io.name
  type = "TXT"
  ttl = "3600" # seconds
  name = "protonmail._domainkey.${data.digitalocean_domain.noahh_io.name}"
  value = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDNDdmnmb+9FGSMvNNzW6S1ZgwLl9BT7FTqvk3/HmvQHxOPir3f+m14BzOEE2kON2GW7pmERxY/+RUGghGj/WD+Uj3JP+RQY/cmFdZ+pjiVZZe3759uFaj3pHnnf9sjXjp5rWunMThuA+buS1pBxRTMVIytWVHuSvEdl0pNOiEaZQIDAQAB"
}

resource "digitalocean_record" "noahh_io_protonmail_dmarc" {
  domain = data.digitalocean_domain.noahh_io.name
  type = "TXT"
  ttl = "3600" # seconds
  name = "_dmarc.${data.digitalocean_domain.noahh_io.name}"
  value = "v=DMARC1; p=none; rua=mailto:contact@noahh.io"
}
