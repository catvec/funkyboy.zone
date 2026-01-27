output "droplet_funkyboy_zone_ipv4" {
    description = "IPv4 address of Funkyboy DigitalOcean droplet"
    value = module.all_cloud.droplet_funkyboy_zone_ipv4
}

output "kubernetes_cluster_name" {
    description = "Name of Kubernetes cluster"
    value = var.kubernetes_cluster_name
}

output "game_deals_spaces_access_key" {
    description = "Access key for game-deals Spaces bucket"
    value = module.all_cloud.game_deals_spaces_access_key
}

output "game_deals_spaces_secret_key" {
    description = "Secret key for game-deals Spaces bucket"
    value = module.all_cloud.game_deals_spaces_secret_key
    sensitive = true
}