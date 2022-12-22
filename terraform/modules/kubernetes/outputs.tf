output "master_endpoint" {
    value = digitalocean_kubernetes_cluster.cluster.endpoint
    description = "URL to Kubernetes master node."
}