data "digitalocean_domain" "gondola-zone" {
	name = "gondola.zone"
}

resource "digitalocean_record" "gondola-zone-wildcard" {
	domain = "${data.digitalocean_domain.gondola-zone.name}"
	type = "A"
	ttl = "60" # seconds
	name = "*"
	value = "${digitalocean_droplet.funkyboy-zone.ipv4_address}"
}

resource "digitalocean_record" "gondola-zone-apex" {
	domain = "${data.digitalocean_domain.gondola-zone.name}"
	type = "A"
	ttl = "60" # seconds
	name = "@"
	value = "${digitalocean_droplet.funkyboy-zone.ipv4_address}"
}
