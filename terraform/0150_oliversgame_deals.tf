data "digitalocean_domain" "oliversgame-deals" {
  name = "oliversgame.deals"
}

resource "digitalocean_record" "oliversgame-deals-wildcard" {
  domain = data.digitalocean_domain.oliversgame-deals.name
  type = "A"
  ttl = "60" # seconds
  name = "*"
  value = digitalocean_droplet.funkyboy-zone.ipv4_address
}

resource "digitalocean_record" "oliversgame-deals-apex" {
  domain = data.digitalocean_domain.oliversgame-deals.name
  type = "A"
  ttl = "60" # seconds
  name = "@"
  value = digitalocean_droplet.funkyboy-zone.ipv4_address
}
