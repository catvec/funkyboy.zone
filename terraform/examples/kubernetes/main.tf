module "kubernetes_cluster" {
  source = "../modules/kubernetes"

  name = "cluster-name"
  region = "nyc1"
  kubernetes_version = "1.22.8"

  node_pools = [
    {
	 name = "worker-pool"
	 size = "s-1vcpu-2gb"
	 node_count = 2
    }
  ]
}
