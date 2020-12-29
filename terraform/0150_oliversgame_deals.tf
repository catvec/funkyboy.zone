data "digitalocean_domain" "oliversgame_deals" {
  name = "oliversgame.deals"
}

resource "digitalocean_record" "oliversgame_deals_wildcard" {
  domain = data.digitalocean_domain.oliversgame_deals.name
  type = "A"
  ttl = "60" # seconds
  name = "*"
  value = digitalocean_droplet.funkyboy_zone.ipv4_address
}

resource "digitalocean_record" "oliversgame_deals_apex" {
  domain = data.digitalocean_domain.oliversgame_deals.name
  type = "A"
  ttl = "60" # seconds
  name = "@"
  value = digitalocean_droplet.funkyboy_zone.ipv4_address
}
