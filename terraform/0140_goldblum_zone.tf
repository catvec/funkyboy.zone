data "digitalocean_domain" "goldblum_zone" {
  name = "goldblum.zone"
}

resource "digitalocean_record" "goldblum_zone_wildcard" {
  domain = data.digitalocean_domain.goldblum_zone.name
  type = "A"
  ttl = "60" # seconds
  name = "*"
  value = digitalocean_droplet.funkyboy_zone.ipv4_address
}

resource "digitalocean_record" "goldblum_zone_apex" {
  domain = data.digitalocean_domain.goldblum_zone.name
  type = "A"
  ttl = "60" # seconds
  name = "@"
  value = digitalocean_droplet.funkyboy_zone.ipv4_address
}

resource "digitalocean_record" "goldblum_zone_keybase" {
  domain = data.digitalocean_domain.goldblum_zone.name
  type = "TXT"
  ttl = "60" # seconds
  name = "@"
  value = "keybase-site-verification=WZW-zpLmYG-6wcbQolAisRi5lrynVWsT2TRDKUv4APM"
}
