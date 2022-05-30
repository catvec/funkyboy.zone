variable "kubeconfig_path" {
  type = string
  description = "Path to the kube config file used to authenticate with the cluster"
  default = "funkyboy-kubeconfig.yaml"
}
