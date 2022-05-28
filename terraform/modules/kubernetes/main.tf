resource "digitalocean_kubernetes_cluster" "cluster" {
  name = var.name
  region = var.region
  version = var.kubernetes_version

  dynamic "node_pool" {
    for_each = var.node_pools
    content {
	 name = node_pool.value.name
	 size = node_pool.value.size
	 node_count = node_pool.value.node_count
    }
  }
}
