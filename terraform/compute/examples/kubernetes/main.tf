module "kubernetes_cluster" {
  source = "../modules/kubernetes"

  name = "cluster-name"
  region = "nyc1"
  kubernetes_version = "1.22.8-do.1"

  kubeconfig_out_path = "${path.root}/kubeconfig.yaml"

  node_pools = [
    {
	 name = "worker-pool"
	 size = "s-1vcpu-2gb"
	 node_count = 2
    }
  ]

  maintenance = {
    day = "sunday"
    start_time = "04:00" # Midnight EST
  }
}
