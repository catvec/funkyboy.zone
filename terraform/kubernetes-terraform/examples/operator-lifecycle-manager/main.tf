module "olm" {
  source = "../modules/operator-lifecycle-manager"
  
  version = "v0.21.2"
}

# Any new Kubernetes resources which use the OLM must then have:
# ```hcl
# depends_on = [ module.olm ]
# ```
