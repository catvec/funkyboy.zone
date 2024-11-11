variable "digitalocean_kubernetes_cluster_name" {
    type = string
    description = "Name of the DigitalOcean Kubernetes cluster"
}

variable "kubernetes_namespace" {
  type = string
  description = "Kubernetes namespace in which target service exists"
}

variable "kubernetes_service" {
  type = string
  description = "Name of Kubernetes LoadBalancer service"
}
