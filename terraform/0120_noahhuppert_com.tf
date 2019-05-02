data "digitalocean_domain" "noahhuppert-com" {
  name = "noahhuppert.com"
}

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

resource "digitalocean_record" "noahhuppert-com-keybase" {
  domain = "${data.digitalocean_domain.noahhuppert-com.name}"
  type = "TXT"
  ttl = "60" # seconds
  name = "_keybase"
  value = "keybase-site-verification=JLTh13lgHP5frw5NRtWBWquFyy2GHCaVHXhph2g6qbQ"
}
