data "digitalocean_kubernetes_cluster" "cluster" {
  name = var.digitalocean_kubernetes_cluster_name
}

data "kubernetes_service" "nginx_ingress_controller" {
  metadata {
    name = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

locals {
  load_balancer_annotation = one(data.kubernetes_service.nginx_ingress_controller.metadata[*].annotations["kubernetes.digitalocean.com/load-balancer-id"])
}

data "digitalocean_loadbalancer" "kubernetes_nginx_ingress" {
  id = local.load_balancer_annotation
}

resource "digitalocean_record" "kubernetes" {
  domain = "funkyboy.zone"
  type = "A"
  ttl = "60" # Seconds
  name = "*.k8s"
  value = data.digitalocean_loadbalancer.kubernetes_nginx_ingress.ip
}