resource "digitalocean_kubernetes_cluster" "cluster" {
  name = var.name
  region = var.region
  version = var.kubernetes_version
  ha = true

  dynamic "node_pool" {
    for_each = toset([ var.primary_node_pool ])
    content {
      name = node_pool.value.name
      size = node_pool.value.size

      node_count = lookup(node_pool.value.node_count, "count", null)

      auto_scale = node_pool.value.node_count.autoscale != null
      min_nodes = node_pool.value.node_count.autoscale != null ? node_pool.value.node_count.autoscale.min : null
      max_nodes = node_pool.value.node_count.autoscale != null ? node_pool.value.node_count.autoscale.max : null
    }
  }

  maintenance_policy {
    day = var.maintenance.day
    start_time = var.maintenance.start_time
  }
}

resource "digitalocean_kubernetes_node_pool" "node_pool" {
  # digitalocean_kubernetes_cluster can only have one node_pool block, additional node pools must be defined using digitalocean_kubernetes_node_pool resources.
  for_each = var.additional_node_pools

  cluster_id = digitalocean_kubernetes_cluster.cluster.id

  name = each.value.name
  size = each.value.size

  node_count = lookup(each.value.node_count, "count", null)

  auto_scale = each.value.node_count.autoscale != null
  min_nodes = each.value.node_count.autoscale != null ? each.value.node_count.autoscale.min : null
  max_nodes = each.value.node_count.autoscale != null ? each.value.node_count.autoscale.max : null
}

resource "local_sensitive_file" "kubeconfig" {
  filename = var.kubeconfig_out_path
  content = digitalocean_kubernetes_cluster.cluster.kube_config[0].raw_config
  file_permission = "0600" # _,owner,group,others
}
