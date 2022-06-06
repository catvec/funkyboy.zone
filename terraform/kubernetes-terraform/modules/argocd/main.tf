module "operator_manifest"{
  source = "../kubernetes-manifests"

  remote_manifests = [
    "https://operatorhub.io/install/argocd-operator.yaml"
  ]
}
