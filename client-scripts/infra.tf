# {{{1 Setup provider
provider "digitalocean" {
	token = "${var.do_token}"
}

# {{{1 Variables
variable "do_token" {
	type = "string"
	description = "Digital Ocean API token"
}

# {{{1 Find manually created resources
data "digitalocean_image" "void-linux" {
	name = "Void-Linux"
}

data "digitalocean_volume" "backup-volume" {
	name = "funkyboy-zone-backup"
}

data "digitalocean_ssh_key" "katla" {
	name = "Katla"
}

data "digitalocean_domain" "funkyboy-zone" {
	name = "funkyboy.zone"
}

data "digitalocean_domain" "noahh-io" {
	name = "noahh.io"
}

data "digitalocean_domain" "noahhuppert-com" {
	name = "noahhuppert.com"
}

# {{{1 Create resources
# {{{2 Droplet
resource "digitalocean_droplet" "funkyboy-zone" {
	name = "funkyboy.zone"
	region = "nyc1"
	image = "${data.digitalocean_image.void-linux.image}"
	size = "s-1vcpu-2gb"
	ssh_keys = [
		"${data.digitalocean_ssh_key.katla.fingerprint}"
	]
	backups = true
}

# {{{2 Volume
resource "digitalocean_volume_attachment" "backup-volume-attach" {
	droplet_id = "${digitalocean_droplet.funkyboy-zone.id}"
	volume_id = "${data.digitalocean_volume.backup-volume.id}"
}

# {{{2 DNS records
# {{{3 funkyboy.zone
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

# {{{3 noahh.io
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


# {{{3 noahhuppert.com
resource "digitalocean_record" "noahhuppert-com-wildcard" {
	domain = "${data.digitalocean_domain.noahhuppert-com.name}"
	type = "A"
	ttl = "60" # seconds
	name = "*"
	value = "${digitalocean_droplet.funkyboy-zone.ipv4_address}"
}

resource "digitalocean_record" "noahhuppert-com-apex" {
	domain = "${data.digitalocean_domain.noahhuppert-com.name}"
	type = "A"
	ttl = "60" # seconds
	name = "@"
	value = "${digitalocean_droplet.funkyboy-zone.ipv4_address}"
}
