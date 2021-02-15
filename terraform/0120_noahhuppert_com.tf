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

resource "digitalocean_record" "noahhuppert_com_protonmail_dkim1" {
  domain = data.digitalocean_domain.noahhuppert_com.name
  type = "CNAME"
  ttl = "60" # seconds
  name = "protonmail._domainkey"
  value = "protonmail.domainkey.d2i3l6setswma5tygpxpd7llkrjpntekxmytca5etovoacggdmrka.domains.proton.ch."
}

resource "digitalocean_record" "noahhuppert_com_protonmail_dkim2" {
  domain = data.digitalocean_domain.noahhuppert_com.name
  type = "CNAME"
  ttl = "60" # seconds
  name = "protonmail2._domainkey"
  value = "protonmail2.domainkey.d2i3l6setswma5tygpxpd7llkrjpntekxmytca5etovoacggdmrka.domains.proton.ch."
}

resource "digitalocean_record" "noahhuppert_com_protonmail_dkim3" {
  domain = data.digitalocean_domain.noahhuppert_com.name
  type = "CNAME"
  ttl = "60" # seconds
  name = "protonmail3._domainkey"
  value = "protonmail3.domainkey.d2i3l6setswma5tygpxpd7llkrjpntekxmytca5etovoacggdmrka.domains.proton.ch."
}

resource "digitalocean_record" "noahhuppert_com_protonmail_dmarc" {
  domain = data.digitalocean_domain.noahhuppert_com.name
  type = "TXT"
  ttl = "3600" # seconds
  name = "_dmarc.${var.domain_noahhuppert_com_name}"
  value = "v=DMARC1; p=none; rua=mailto:contact@noahhuppert.com"
}
