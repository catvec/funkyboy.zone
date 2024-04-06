locals {
    primary_node_pool_valid = (var.primary_node_pool.node_count.autoscale != null) == (var.primary_node_pool.node_count.count != null) ? tobool("either autoscale or count in primary_node_pool.node_count must be set") : true
    additional_node_pools_valid = [
        for key, spec in var.additional_node_pools : (spec.node_count.autoscale != null) == (spec.node_count.count != null) ? tobool("either autoscale or count in additional_node_pools.${key}.node_count must be set") : true
    ]
}