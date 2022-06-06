module "operator_manifest"{
  source = "../kubernetes-manifest"

  remote_manifests = [
    "https://operatorhub.io/install/argocd-operator.yaml"
  ]
}
