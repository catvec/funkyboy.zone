data "http" "yamls" {
  count = length(var.remote_manifests)

  url = var.remote_manifests[count.index]
}

resource "kubectl_manifest" "apply" {
  count = length(var.remote_manifests)
  
  yaml_body = data.http.yamls[count.index].body
}
