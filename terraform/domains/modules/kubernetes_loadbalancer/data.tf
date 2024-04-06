data "digitalocean_kubernetes_cluster" "cluster" {
  name = var.digitalocean_kubernetes_cluster_name
}

data "kubernetes_service" "nginx_ingress_controller" {
  metadata {
    name = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

data "digitalocean_loadbalancer" "kubernetes_nginx_ingress" {
  id = one(data.kubernetes_service.nginx_ingress_controller.metadata[*].annotations["kubernetes.digitalocean.com/load-balancer-id"])
}