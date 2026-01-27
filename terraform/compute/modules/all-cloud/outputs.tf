output "droplet_funkyboy_zone_ipv4" {
    description = "IPv4 address of Funkyboy DigitalOcean droplet"
    value = digitalocean_droplet.funkyboy_zone.ipv4_address
}

output "game_deals_spaces_access_key" {
    description = "Access key for game-deals Spaces bucket"
    value = digitalocean_spaces_key.game_deals.access_key
}

output "game_deals_spaces_secret_key" {
    description = "Secret key for game-deals Spaces bucket"
    value = digitalocean_spaces_key.game_deals.secret_key
    sensitive = true
}