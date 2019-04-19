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

resource "digitalocean_record" "gondola-zone-keybase" {
	domain = "${data.digitalocean_domain.gondola-zone.name}"
	type = "TXT"
	ttl = "60" # seconds
	name = "@"
	value = "keybase-site-verification=crd9ptToil_MjfIHdmjch3MP5NmhnKnNXulZ5sEpA30"
}
