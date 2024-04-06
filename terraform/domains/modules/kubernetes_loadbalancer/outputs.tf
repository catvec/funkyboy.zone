output "kubernetes_loadbalancer_ipv4" {
    description = "IP of Kubernetes ingress load balancer"
    value = data.digitalocean_loadbalancer.kubernetes_nginx_ingress.ip
}