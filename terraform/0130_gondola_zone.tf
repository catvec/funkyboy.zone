data "digitalocean_domain" "gondola_zone" {
  name = "gondola.zone"
}

resource "digitalocean_record" "gondola_zone_wildcard" {
  domain = data.digitalocean_domain.gondola_zone.name
  type = "A"
  ttl = "60" # seconds
  name = "*"
  value = digitalocean_droplet.funkyboy_zone.ipv4_address
}

resource "digitalocean_record" "gondola_zone_apex" {
  domain = data.digitalocean_domain.gondola_zone.name
  type = "A"
  ttl = "60" # seconds
  name = "@"
  value = digitalocean_droplet.funkyboy_zone.ipv4_address
}

resource "digitalocean_record" "gondola_zone_keybase" {
  domain = data.digitalocean_domain.gondola_zone.name
  type = "TXT"
  ttl = "60" # seconds
  name = "@"
  value = "keybase-site-verification=crd9ptToil_MjfIHdmjch3MP5NmhnKnNXulZ5sEpA30"
}
