# Content records
data "digitalocean_domain" "domain" {
  name = var.name
}

resource "digitalocean_record" "record_wildcard" {
  domain = var.name
  type = "A"
  ttl = "60" # seconds
  name = "*"
  value = var.target
}

resource "digitalocean_record" "record_apex" {
  domain = var.name
  type = "A"
  ttl = "60" # seconds
  name = "@"
  value = var.target
}

# Verification records
resource "digitalocean_record" "record_spf" {
  domain = var.name
  type = "TXT"
  ttl = "60" # seconds
  name = "@"
  value = var.spf
}


resource "digitalocean_record" "record_keybase" {
  count = var.keybase_verification != "" ? 1 : 0
  domain = var.name
  type = "TXT"
  ttl = "60" # seconds
  name = "_keybase"
  value = var.keybase_verification
}

resource "digitalocean_record" "record_protonmail_mx10" {
  count = length(var.mx) > 0 ? 1 : 0
  domain = var.name
  type = "MX"
  ttl = "1800" # seconds
  name = "@"
  priority = 10
  value = var.mx[0]
}

resource "digitalocean_record" "record_protonmail_mx20" {
  count = length(var.mx) > 0 ? 1 : 0
  domain = var.name
  type = "MX"
  ttl = "1800" # seconds
  name = "@"
  priority = 20
  value = var.mx[1]
}

resource "digitalocean_record" "record_protonmail_dkim1" {
  count = length(var.mx) > 0 ? 1 : 0
  domain = var.name
  type = "CNAME"
  ttl = "60" # seconds
  name = var.dkim[0][0]
  value = var.dkim[0][1]
}

resource "digitalocean_record" "record_protonmail_dkim2" {
  count = length(var.mx) > 0 ? 1 : 0
  domain = var.name
  type = "CNAME"
  ttl = "60" # seconds
  name = var.dkim[1][0]
  value = var.dkim[1][1]
}

resource "digitalocean_record" "record_protonmail_dkim3" {
  count = length(var.mx) > 0 ? 1 : 0
  domain = var.name
  type = "CNAME"
  ttl = "60" # seconds
  name = var.dkim[2][0]
  value = var.dkim[2][1]
}

resource "digitalocean_record" "record_protonmail_dmarc" {
  count = length(var.mx) > 0 ? 1 : 0
  domain = var.name
  type = "TXT"
  ttl = "3600" # seconds
  name = "_dmarc.${var.name}"
  value = var.dmarc
}

resource "digitalocean_record" "record_protonmail_verification" {
  count = length(var.mx) > 0 ? 1 : 0
  domain = var.name
  type = "TXT"
  ttl = "1800" # seconds
  name = "@"
  value = var.protonmail_verification
}
