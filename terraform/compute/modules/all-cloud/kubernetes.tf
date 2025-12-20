module "kubernetes_cluster" {
  source = "../kubernetes"

  name = var.kubernetes_cluster_name
  region = "nyc1"
  # Run `doctl kubernetes options versions` to get the versions (Note if near the end of support for current version this command may not show all available versions, go to DO dashboard and click upgrade button on cluster to see what the next version is)
  kubernetes_version = "1.32.10-do.2"

  kubeconfig_out_path = "${path.root}/../../kubernetes/kubeconfig.yaml"

  primary_node_pool = {
    name = "worker-pool-dedicated-cpu-b"
    size = "c-4"
    node_count = {
      autoscale = {
        min = 1
        max = 2
      }
    }
  }

  maintenance = {
    day = "sunday"
    start_time = "04:00" # Midnight EST
  }
}
