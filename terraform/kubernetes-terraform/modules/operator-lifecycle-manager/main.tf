module "manifests" {
  source = "../kubernetes-manifests"
  
  remote_manifests = [
    "https://raw.githubusercontent.com/operator-framework/operator-lifecycle-manager/${var.version_tag}/deploy/upstream/quickstart/crds.yaml",
    "https://raw.githubusercontent.com/operator-framework/operator-lifecycle-manager/${var.version_tag}/deploy/upstream/quickstart/olm.yaml",
  ]
}
