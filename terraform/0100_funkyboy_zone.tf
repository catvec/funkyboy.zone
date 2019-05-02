data "digitalocean_domain" "funkyboy-zone" {
  name = "funkyboy.zone"
}

resource "digitalocean_record" "funkyboy-zone-wildcard" {
  domain = "${data.digitalocean_domain.funkyboy-zone.name}"
  type = "A"
  ttl = "60" # seconds
  name = "*"
  value = "${digitalocean_droplet.funkyboy-zone.ipv4_address}"
}

resource "digitalocean_record" "funkyboy-zone-apex" {
  domain = "${data.digitalocean_domain.funkyboy-zone.name}"
  type = "A"
  ttl = "60" # seconds
  name = "@"
  value = "${digitalocean_droplet.funkyboy-zone.ipv4_address}"
}

resource "digitalocean_record" "funkyboy-zone-spf" {
  domain = "${data.digitalocean_domain.funkyboy-zone.name}"
  type = "TXT"
  ttl = "60" # seconds
  name = "@"
  value = "v=spf1 a ~all"
}

resource "digitalocean_record" "funkyboy-zone-dkim" {
  domain = "${data.digitalocean_domain.funkyboy-zone.name}"
  type = "TXT"
  ttl = "60" # seconds
  name = "mail._domainkey"
  value = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCdcDWpmBhFyplyLIqtosoThOcuKMst2U4BSKdkmP0/MauCShyTK4xnMEWjc07hMogN5n39j66DoBxccO2KLf0BYOCAnl7aaaorM7hRujvgkg7gYwbYG2tm9TMQRUTnbVkfSCKN2sz6oftpQXYzZxU7rGwOtBqxK4SyMFz0V0rNSwIDAQAB"
}

resource "digitalocean_record" "funkyboy-zone-keybase" {
  domain = "${data.digitalocean_domain.funkyboy-zone.name}"
  type = "TXT"
  ttl = "60" # seconds
  name = "@"
  value = "keybase-site-verification=29OQirPLhHqrbRfkhsdWl45XyYDZ537bFU2sh1zsW-A"
}
