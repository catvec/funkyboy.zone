output "droplet_funkyboy_zone_ipv4" {
    description = "IPv4 address of Funkyboy DigitalOcean droplet"
    value = module.all_cloud.droplet_funkyboy_zone_ipv4
}

output "kubernetes_cluster_name" {
    description = "Name of Kubernetes cluster"
    value = var.kubernetes_cluster_name
}