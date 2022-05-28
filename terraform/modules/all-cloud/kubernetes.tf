module "kubernetes_cluster" {
  source = "../kubernetes"

  name = "funkyboy"
  region = "nyc1"
  kubernetes_version = "1.22.8"

  node_pools = [
    {
	 name = "worker-pool-a"
	 size = "s-1vcpu-2gb"
	 node_count = 2
    }
  ]
}
