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
      "wiki": local.k8s_record,
      "modes": local.k8s_record,
      "*.k8s": local.k8s_record,
      # "factorio" = {
      #   type = "A",
      #   value = module.k8s_factorio_lb.kubernetes_loadbalancer_ipv4
      #   ttl = 60
      # },
      "infoline" = {
        type = "NS"
        value = "k8s.funkyboy.zone."
        ttl = 60
      },
      "ham-radio-questions" = local.k8s_record,
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
    "goldblum.zone" = {
      "@": local.k8s_record,
      "*": local.k8s_record,
    },
    "oliversgame.deals" = local.default_targets
    "4e48.dev" = local.default_targets
    "turtle.wiki" = local.default_targets
  }
}

variable "keybase_verification" {
  type = map(string)
  description = "Keybase DNS ownership verification entries."
  default = {
    "funkyboy.zone": "",
    "noahh.io": "",
    "noahhuppert.com": "",
    "goldblum.zone": "",
    "oliversgame.deals": "",
    "4e48.dev": "",
    "turtle.wiki": "",
  }
}

variable "spf_email" {
  type = string
  description = "SPF value if email is enabled for a domain."
  default = "v=spf1 include:_spf.protonmail.ch ~all"
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
        priority = 10
        value = "mail.protonmail.ch."
      }
      secondary = {
        priority = 20
        value = "mailsec.protonmail.ch."
      }
    },
    "noahhuppert.com": {
      primary = {
        priority = 10
        value = "mail.protonmail.ch."
      }
      secondary = {
        priority = 20
        value = "mailsec.protonmail.ch."
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
        name = "protonmail._domainkey"
        value = "protonmail.domainkey.dhngagtoz5n6777wkmvw6ll2aqlow4wpnwisycw6oabxgrxih5m6a.domains.proton.ch."
      }
      secondary = {
        name = "protonmail2._domainkey"
        value = "protonmail2.domainkey.dhngagtoz5n6777wkmvw6ll2aqlow4wpnwisycw6oabxgrxih5m6a.domains.proton.ch."
      }
      tertiary = {
        name = "protonmail3._domainkey"
        value = "protonmail3.domainkey.dhngagtoz5n6777wkmvw6ll2aqlow4wpnwisycw6oabxgrxih5m6a.domains.proton.ch."
      }
    } 
    "noahhuppert.com": {
      primary = {
        name = "protonmail._domainkey"
        value = "protonmail.domainkey.d2i3l6setswma5tygpxpd7llkrjpntekxmytca5etovoacggdmrka.domains.proton.ch."
      }
      secondary = {
        name = "protonmail2._domainkey"
        value = "protonmail2.domainkey.d2i3l6setswma5tygpxpd7llkrjpntekxmytca5etovoacggdmrka.domains.proton.ch."
      }
      tertiary = {
        name = "protonmail3._domainkey"
        value = "protonmail3.domainkey.d2i3l6setswma5tygpxpd7llkrjpntekxmytca5etovoacggdmrka.domains.proton.ch."
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
    "noahh.io": "v=DMARC1; p=quarantine"
    "noahhuppert.com": "v=DMARC1; p=quarantine"
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
    "noahh.io": null,
    "noahhuppert.com": null,
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

# module "k8s_factorio_lb" {
#   source = "./modules/kubernetes_loadbalancer"

#   digitalocean_kubernetes_cluster_name = data.terraform_remote_state.compute.outputs.kubernetes_cluster_name
#   kubernetes_namespace = "factorio"
#   kubernetes_service = "factorio-rev1"
# }

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
