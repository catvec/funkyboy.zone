# Zone
variable "domain_4e48_dev_name" {
  type = string
  description = "Name of 4e48.dev domain"
  default = "4e48.dev"
}

variable "minecraft_server_ipv4" {
  type = string
  description = "IPv4 address of minecraft server"
  default = "34.238.12.88"
}

data "digitalocean_domain" "domain_4e48_dev" {
  name = var.domain_4e48_dev_name
}

# Records
resource "digitalocean_record" "domain_4e48_dev_wildcard" {
  domain = data.digitalocean_domain.domain_4e48_dev.name
  type = "A"
  ttl = "60" # seconds
  name = "*"
  value = digitalocean_droplet.funkyboy_zone.ipv4_address
}

resource "digitalocean_record" "domain_4e48_dev_apex" {
  domain = data.digitalocean_domain.domain_4e48_dev.name
  type = "A"
  ttl = "60" # seconds
  name = "@"
  value = digitalocean_droplet.funkyboy_zone.ipv4_address
}

resource "digitalocean_record" "domain_4e48_dev_minecraft" {
  domain = data.digitalocean_domain.domain_4e48_dev.name
  type = "A"
  ttl = "60" # seconds
  name = "minecraft"
  value = var.minecraft_server_ipv4
}

