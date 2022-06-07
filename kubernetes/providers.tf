provider "kubectl" {
  config_path = var.kubeconfig_path
}

provider "remote" {
}
