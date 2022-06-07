module "crds_manifest" {
  source = "../kubernetes-manifests"
  
  remote_manifest = "https://raw.githubusercontent.com/operator-framework/operator-lifecycle-manager/${var.version_tag}/deploy/upstream/quickstart/crds.yaml"
}

module "olm_manifest" {
  source = "../kubernetes-manifests"
  
  remote_manifest = "https://raw.githubusercontent.com/operator-framework/operator-lifecycle-manager/${var.version_tag}/deploy/upstream/quickstart/olm.yaml"
}
