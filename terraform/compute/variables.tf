variable "do_token" {
  type = string
  description = "Digital Ocean API token."
}

variable "aws_region" {
  type = string
  description = "AWS region."
  default = "us-east-1"
}

variable "kubernetes_cluster_name" {
  type = string
  description = "Name of Kubernetes cluster"
  default = "funkyboy"
}