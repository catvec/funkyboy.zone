variable "do_token" {
  type = string
  description = "Digital Ocean API token."
}

variable "digitalocean_kubernetes_cluster_name" {
    type = string
    description = "Name of the DigitalOcean Kubernetes cluster"
    default = "funkyboy"
}

variable "digitalocean_domain_name" {
    type = string
    description = "Name of DigitalOcean domain name in which to create Kubernetes record"
    default = "funkyboy.zone"
}