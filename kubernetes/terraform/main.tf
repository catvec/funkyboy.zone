data "digitalocean_kubernetes_cluster" "cluster" {
  name = var.digitalocean_kubernetes_cluster_name
}

data "kubernetes_service" "nginx_ingress_controller" {
  metadata {
    name = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

resource "digitalocean_record" "kubernetes" {
  domain = "funkyboy.zone"
  type = "A"
  ttl = "60" # Seconds
  name = "*.k8s"
  value = one(data.kubernetes_service.nginx_ingress_controller.status.0.load_balancer.0.ingress[*].ip)
}