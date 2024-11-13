variable "domains" {
  type = list(string)
  description = "List of domain names."
  default = [
    "funkyboy.zone",
    "noahh.io",
    "noahhuppert.com",
    "goldblum.zone",
    "oliversgame.deals",
    "4e48.dev",
    "turtle.wiki",
  ]
}

locals {
  droplet_record = {
    type = "A"
    value = data.terraform_remote_state.compute.outputs.droplet_funkyboy_zone_ipv4
    ttl = 60
  }
  k8s_record = {
    type = "A"
    value = module.k8s_nginx_ingress_lb.kubernetes_loadbalancer_ipv4
    ttl = 60
  }
  default_targets = {
    "*": local.droplet_record,
    "@": local.droplet_record,
  }
  targets = {
    "funkyboy.zone" = {
      "@": local.k8s_record,
      "www": local.k8s_record,
      "*.k8s": {
        type = "A",
        value = module.k8s_nginx_ingress_lb.kubernetes_loadbalancer_ipv4
        ttl = 60
      },
      "factorio" = {
        type = "A",
        value = module.k8s_factorio_lb.kubernetes_loadbalancer_ipv4
        ttl = 60
      },
      "infoline" = {
        type = "NS"
        value = "k8s.funkyboy.zone."
        ttl = 60
      },
    },
    "noahh.io" = {
      "@": local.k8s_record,
      "www": local.k8s_record,
      "*": local.k8s_record,
    },
    "noahhuppert.com" = {
      "@": local.k8s_record,
      "www": local.k8s_record,
      "*": local.k8s_record,
    },
    "goldblum.zone" = local.default_targets
    "oliversgame.deals" = local.default_targets
    "4e48.dev" = local.default_targets
    "turtle.wiki" = local.default_targets
  }
}

variable "keybase_verification" {
  type = map(string)
  description = "Keybase DNS ownership verification entries."
  default = {
    "funkyboy.zone": "keybase-site-verification=29OQirPLhHqrbRfkhsdWl45XyYDZ537bFU2sh1zsW-A",
    "noahh.io": "keybase-site-verification=qLC-aj3hDn591K3qx2EX-aiZTb09QLlk2IY4BmuOBmI",
    "noahhuppert.com": "keybase-site-verification=JLTh13lgHP5frw5NRtWBWquFyy2GHCaVHXhph2g6qbQ",
    "goldblum.zone": "keybase-site-verification=WZW-zpLmYG-6wcbQolAisRi5lrynVWsT2TRDKUv4APM",
    "oliversgame.deals": "",
    "4e48.dev": "",
    "turtle.wiki": "",
  }
}

variable "spf_email" {
  type = string
  description = "SPF value if email is enabled for a domain."
  default = "v=spf1 include:_spf.google.com ~all"
}

variable "spf_no_email" {
  type = string
  description = "SPF value if there is no email for a domain."
  default = "v=spf1 a ~all"
}

variable "mx" {
  type = map(map(object({
    priority = number
    value = string
  })))
  description = "Mail server MX DNS records."
  default = {
    "funkyboy.zone": {},
    "noahh.io": {
      primary = {
        priority = 1
        value = "smtp.google.com."
      }
    },
    "noahhuppert.com": {
      primary = {
        priority = 1
        value = "smtp.google.com."
      }
    },
    "goldblum.zone": {},
    "oliversgame.deals": {},
    "4e48.dev": {},
    "turtle.wiki": {},
  }
}

variable "dkim" {
  type = map(map(object({
    name = string
    value = string
  })))
  description = "DKIM DNS entries for domains."
  default = {
    "funkyboy.zone" = {},
    "noahh.io" = {
      primary = {
        name = "google._domainkey"
        value = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAglt8qyzwlzFOqM3mr4iv+Qs6trp7jq6HVbpwtrfxloFtqMXhiNquBLa/2EyL1LNS/2MknXTWq4Wa3rz/lQy1oagW2aFE9ZKpre6dl2wXv++mzyP6lLCYFcn/24IFzRYzHkJpmZru8MbZtIEVtas0ZDXRZicKqhKGfM21E9lxDWD80uRRSuuDl92uPkLaNXjoWHAIyqhcd6+uluqqW0/aItVE1XoaiV6VticNHdEZlGSNdXGCxMUMFYvcerGSWLeuFpmb4YchwS0DZT9o5kBCUpDSBuMG1zOGYoAoDB2Olq7vdRgh5CjCLr/ImtIoqL2MgEtOEp3rCuXhf9hMYPRlNQIDAQAB",
      }
    } 
    "noahhuppert.com": {
      primary = {
        name = "google._domainkey"
        value = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAglt8qyzwlzFOqM3mr4iv+Qs6trp7jq6HVbpwtrfxloFtqMXhiNquBLa/2EyL1LNS/2MknXTWq4Wa3rz/lQy1oagW2aFE9ZKpre6dl2wXv++mzyP6lLCYFcn/24IFzRYzHkJpmZru8MbZtIEVtas0ZDXRZicKqhKGfM21E9lxDWD80uRRSuuDl92uPkLaNXjoWHAIyqhcd6+uluqqW0/aItVE1XoaiV6VticNHdEZlGSNdXGCxMUMFYvcerGSWLeuFpmb4YchwS0DZT9o5kBCUpDSBuMG1zOGYoAoDB2Olq7vdRgh5CjCLr/ImtIoqL2MgEtOEp3rCuXhf9hMYPRlNQIDAQAB"
      }
    },
    "goldblum.zone": {},
    "oliversgame.deals": {},
    "4e48.dev": {},
    "turtle.wiki": {},
  }
}

variable "dmarc" {
  type = map(string)
  description = "DMARC policies for domains."
  default = {
    "funkyboy.zone": "",
    "noahh.io": "v=DMARC1; p=none; rua=mailto:webmaster@noahh.io",
    "noahhuppert.com": "v=DMARC1; p=none; rua=mailto:webmaster@noahhuppert.com",
    "goldblum.zone": "",
    "oliversgame.deals": "",
    "4e48.dev": "",
    "turtle.wiki": "",
  }
}

variable "protonmail_verification" {
  type = map(string)
  description = "Protonmail domain ownership verification."
  default = {
    "funkyboy.zone": "",
    "noahh.io": "protonmail-verification=22cdd158fff490e87ec1b1964e266de6935e653a",
    "noahhuppert.com": "protonmail-verification=445adbc2c30dfd5f7e79ff00b0254cc6d65b6841",
    "goldblum.zone": "",
    "oliversgame.deals": "",
    "4e48.dev": "",
    "turtle.wiki": "",
  }
}

variable "google_verification" {
  type = map(string)
  description = "Google domain ownership verification."
  default = {
    "funkyboy.zone": null,
    "noahh.io": "google-site-verification=vK90NUyqv5bx45cdFezI3tKOtAMJZBteDHVTRUvEu9o",
    "noahhuppert.com": "google-site-verification=ROilJT-7D-FpAfySybb64ZNk3iAwuAgpl67rCnnPIKc",
    "goldblum.zone": null,
    "oliversgame.deals": null,
    "4e48.dev": null,
    "turtle.wiki": null,
  }
}

module "k8s_nginx_ingress_lb" {
  source = "./modules/kubernetes_loadbalancer"

  digitalocean_kubernetes_cluster_name = data.terraform_remote_state.compute.outputs.kubernetes_cluster_name
  kubernetes_namespace = "ingress-nginx"
  kubernetes_service = "ingress-nginx-controller"
}

module "k8s_factorio_lb" {
  source = "./modules/kubernetes_loadbalancer"

  digitalocean_kubernetes_cluster_name = data.terraform_remote_state.compute.outputs.kubernetes_cluster_name
  kubernetes_namespace = "factorio"
  kubernetes_service = "factorio-rev1"
}

module "domains" {
  source = "./modules/domain"
  for_each = toset(var.domains)

  name = each.key
  target = local.targets[each.key]
  spf = length(var.mx[each.key]) > 0 ? var.spf_email : var.spf_no_email
  keybase_verification = var.keybase_verification[each.key]
  mx = var.mx[each.key]
  dkim = var.dkim[each.key]
  dmarc = var.dmarc[each.key]
  protonmail_verification = var.protonmail_verification[each.key]
  google_verification = var.google_verification[each.key]
}
