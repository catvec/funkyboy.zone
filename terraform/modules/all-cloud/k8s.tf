module "k8s" {
  source = "../k8s"

  name = "funkyboy"
  region = "nyc1"
  version = "1.22.8"

  node_pools = [
    {
	 name = "worker-pool-a"
	 size = "s-1vcpu-2gb"
	 node_count = 2
    }
  ]
}
