module "olm" {
  source = "./modules/operator-lifecycle-manager"
  
  version_tag = "v0.21.2"
}
