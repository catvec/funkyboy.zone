# All records with the same name must have the same TTL according to the DNS spec
# See: https://github.com/digitalocean/terraform-provider-digitalocean/issues/1012
#      https://www.rfc-editor.org/rfc/rfc2181#section-5

# Content records
data "digitalocean_domain" "domain" {
  name = var.name
}

resource "digitalocean_record" "record_wildcard" {
  for_each = var.target

  domain = var.name
  type = each.value.type
  ttl = each.value.ttl # seconds
  name = each.key
  value = each.value.value
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

resource "digitalocean_record" "record_protonmail_mx" {
  for_each = var.mx
  domain = var.name
  type = "MX"
  ttl = "60" # seconds
  name = "@"
  priority = each.value.priority
  value = each.value.value
}

resource "digitalocean_record" "record_protonmail_dkim" {
  for_each = var.dkim
  domain = var.name
  type = "TXT"
  ttl = "60" # seconds
  name = each.value.name
  value = each.value.value
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
  ttl = "60" # seconds
  name = "@"
  value = var.protonmail_verification
}

resource "digitalocean_record" "record_google_verification" {
  count = length(var.mx) > 0 && var.google_verification != null ? 1 : 0
  domain = var.name
  type = "TXT"
  ttl = "60" # seconds
  name = "@"
  value = var.google_verification
}