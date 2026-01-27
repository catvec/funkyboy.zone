variable "do_token" {
  type        = string
  description = "Digital Ocean API token."
}

variable "spaces_access_id" {
  type        = string
  description = "DigitalOcean Spaces access key ID. Create at DO console: Settings > API > Spaces Keys."
}

variable "spaces_secret_key" {
  type        = string
  sensitive   = true
  description = "DigitalOcean Spaces secret key. Create at DO console: Settings > API > Spaces Keys."
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