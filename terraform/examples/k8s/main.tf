module "cluster" {
  source = "../modules/k8s"

  name = "cluster-name"
  region = "nyc1"
  version = "1.22.8"

  node_pools = [
    {
	 name = "worker-pool"
	 size = "s-1vcpu-2gb"
	 node_count = 2
    }
  ]
}
