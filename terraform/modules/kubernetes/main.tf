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

  maintenance_policy {
    day = var.maintenance.day
    start_time = var.maintenance.start_time
  }
}

resource "local_sensitive_file" "kubeconfig" {
  filename = var.kubeconfig_out_path
  content = digitalocean_kubernetes_cluster.cluster.kube_config[0].raw_config
  file_permission = "0600" # _,owner,group,others
}
