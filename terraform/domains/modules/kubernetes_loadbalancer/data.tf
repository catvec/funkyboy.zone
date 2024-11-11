data "digitalocean_kubernetes_cluster" "cluster" {
  name = var.digitalocean_kubernetes_cluster_name
}

data "kubernetes_service" "target" {
  metadata {
    name = var.kubernetes_service
    namespace = var.kubernetes_namespace
  }
}

data "digitalocean_loadbalancer" "target" {
  id = one(data.kubernetes_service.target.metadata[*].annotations["kubernetes.digitalocean.com/load-balancer-id"])
}
