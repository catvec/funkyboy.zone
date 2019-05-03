data "digitalocean_domain" "goldblum-zone" {
  name = "goldblum.zone"
}

resource "digitalocean_record" "goldblum-zone-wildcard" {
  domain = "${data.digitalocean_domain.goldblum-zone.name}"
  type = "A"
  ttl = "60" # seconds
  name = "*"
  value = "${digitalocean_droplet.funkyboy-zone.ipv4_address}"
}

resource "digitalocean_record" "goldblum-zone-apex" {
  domain = "${data.digitalocean_domain.goldblum-zone.name}"
  type = "A"
  ttl = "60" # seconds
  name = "@"
  value = "${digitalocean_droplet.funkyboy-zone.ipv4_address}"
}

resource "digitalocean_record" "goldblum-zone-keybase" {
  domain = "${data.digitalocean_domain.goldblum-zone.name}"
  type = "TXT"
  ttl = "60" # seconds
  name = "@"
  value = "keybase-site-verification=WZW-zpLmYG-6wcbQolAisRi5lrynVWsT2TRDKUv4APM"
}
