output "droplet_funkyboy_zone_ipv4" {
    description = "IPv4 address of Funkyboy DigitalOcean droplet"
    value = digitalocean_droplet.funkyboy_zone.ipv4_address
}