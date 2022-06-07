data "http" "yaml" {
  url = var.remote_manifest
}

data "kubectl_file_documents" "manifest" {
  content = data.http.yaml.body
}

resource "kubectl_manifest" "apply" {
  for_each = data.kubectl_file_documents.manifest.manifests
  
  yaml_body = each.value # data.kubectl_file_documents.manifest.documents[count.index]
}
