module "operator_manifest"{
  source = "../kubernetes-manifests"

  remote_manifest = "https://operatorhub.io/install/argocd-operator.yaml"
}
