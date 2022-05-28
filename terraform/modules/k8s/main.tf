resource "digitalocean_kubernetes_cluster" "cluster" {
  name = var.name
  region = var.region
  version = var.version

  dynamic "node_pool" {
    for_each = var.node_pools
    content {
	 name = node_pool.name
	 size = node_pool.size
	 node_count = node_pool.node_count
    }
  }
}
