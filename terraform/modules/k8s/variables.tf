variable "name" {
  type = string
  description = "Name of the Kubernetes cluster"
}

variable "region" {
  type = string
  description = "Identifier of DigitalOcean region in which the cluster will be created"
}

variable "version" {
  type = string
  description = "Kubernetes cluster version"
}

variable "node_pools" {
  type = list(object({
    name = string
    size = number
    node_count = number
  }))
  description = "Worker node pool definitions"
}
