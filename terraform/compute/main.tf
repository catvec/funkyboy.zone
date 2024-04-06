module "all_cloud" {
  source = "./modules/all-cloud"

  kubernetes_cluster_name = var.kubernetes_cluster_name
}
