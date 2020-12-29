# Zone
variable "domain_turtle_wiki_name" {
  type = string
  description = "Name of turtle.wiki domain"
  default = "turtle.wiki"
}

data "digitalocean_domain" "turtle_wiki" {
  name = var.domain_turtle_wiki_name
}

# Records
resource "digitalocean_record" "turtle_wiki_wildcard" {
  domain = data.digitalocean_domain.turtle_wiki.name
  type = "A"
  ttl = "60" # seconds
  name = "*"
  value = digitalocean_droplet.funkyboy_zone.ipv4_address
}

resource "digitalocean_record" "turtle_wiki_apex" {
  domain = data.digitalocean_domain.turtle_wiki.name
  type = "A"
  ttl = "60" # seconds
  name = "@"
  value = digitalocean_droplet.funkyboy_zone.ipv4_address
}
