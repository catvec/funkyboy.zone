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
  load_balancer_ip = one(data.kubernetes_service.nginx_ingress_controller.status.0.load_balancer.0.ingress[*].ip)
}

resource "digitalocean_record" "kubernetes" {
  domain = "funkyboy.zone"
  type = "A"
  ttl = "60" # Seconds
  name = "*.k8s"
  value = local.load_balancer_ip != null && local.load_balancer_ip != "" ? local.load_balancer_ip : "127.0.0.1"
}