module "kubernetes_cluster" {
  source = "../kubernetes"

  name = var.kubernetes_cluster_name
  region = "nyc1"
  kubernetes_version = "1.28.11-do.0"

  kubeconfig_out_path = "${path.root}/../../kubernetes/kubeconfig.yaml"

  primary_node_pool = {
    name = "worker-pool-b"
    size = "s-2vcpu-4gb" # "s-4vcpu-8gb"
    node_count = {
      autoscale = {
        min = 2
        max = 4
      }
    }
  }

  maintenance = {
    day = "sunday"
    start_time = "04:00" # Midnight EST
  }
}
