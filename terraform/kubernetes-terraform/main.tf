module "olm" {
  source = "./modules/operator-lifecycle-manager"
  
  version_tag = "v0.21.2"
}

module "argocd" {
  source = "./modules/argocd"

  depends_on = [
    module.olm,
  ]
}
