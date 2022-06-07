module "example_manifests" {
  source = "../modules/kubernetes-manifests"

  remote_manifests = [
    "https://example.com/manifest-a.yaml",
    "https://examples.com/manifest-b.yaml",
  ]
}
