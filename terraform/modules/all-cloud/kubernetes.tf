module "kubernetes_cluster" {
  source = "../kubernetes"

  name = "funkyboy"
  region = "nyc1"
  kubernetes_version = "1.22.8-do.1"

  kubeconfig_out_path = "${path.root}/../kubernetes/kubeconfig.yaml"

  node_pools = [
    {
	 name = "worker-pool-a"
	 size = "s-1vcpu-2gb"
	 node_count = 2
    }
  ]

  maintenance = {
    day = "sunday"
    start_time = "04:00" # Midnight EST
  }
}
