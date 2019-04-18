data "digitalocean_domain" "noahh-io" {
	name = "noahh.io"
}

resource "digitalocean_record" "noahh-io-wildcard" {
	domain = "${data.digitalocean_domain.noahh-io.name}"
	type = "A"
	ttl = "60" # seconds
	name = "*"
	value = "${digitalocean_droplet.funkyboy-zone.ipv4_address}"
}

resource "digitalocean_record" "noahh-io-apex" {
	domain = "${data.digitalocean_domain.noahh-io.name}"
	type = "A"
	ttl = "60" # seconds
	name = "@"
	value = "${digitalocean_droplet.funkyboy-zone.ipv4_address}"
}

resource "digitalocean_record" "noahh-io-keybase" {
	domain = "${data.digitalocean_domain.noahh-io.name}"
	type = "TXT"
	ttl = "60" # seconds
	name = "_keybase"
	value = "keybase-site-verification=qLC-aj3hDn591K3qx2EX-aiZTb09QLlk2IY4BmuOBmI"
}
