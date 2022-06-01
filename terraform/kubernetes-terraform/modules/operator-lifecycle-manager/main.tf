data "http" "crds_yaml" {
  url = "https://raw.githubusercontent.com/operator-framework/operator-lifecycle-manager/${var.version_tag}/deploy/upstream/quickstart/crds.yaml"
}

data "http" "olm_yaml" {
  url = "https://raw.githubusercontent.com/operator-framework/operator-lifecycle-manager/${var.version_tag}/deploy/upstream/quickstart/olm.yaml"
}

resource "kubectl_manifest" "crds" {
  yaml_body = data.http.crds_yaml.body
}

resource "kubectl_manifest" "olm" {
  yaml_body = data.http.olm_yaml.body
}
