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
  default = "v=spf1 include:_spf.protonmail.ch mx ~all"
}

variable "spf_no_email" {
  type = string
  description = "SPF value if there is no email for a domain."
  default = "v=spf1 a ~all"
}

variable "mx" {
  type = map(list(string))
  description = "Mail server MX DNS records."
  default = {
    "funkyboy.zone": [],
    "noahh.io": [
	 "mail.protonmail.ch.",
	 "mailsec.protonmail.ch.",
    ],
    "noahhuppert.com": [
	 "mail.protonmail.ch.",
	 "mailsec.protonmail.ch.",
    ],
    "goldblum.zone": [],
    "oliversgame.deals": [],
    "4e48.dev": [],
    "turtle.wiki": [],
  }
}

variable "dkim" {
  type = map(list(tuple([string, string])))
  description = "DKIM DNS entries for domains."
  default = {
    "funkyboy.zone": [],
    "noahh.io": [
	 [
	   "protonmail._domainkey",
	   "protonmail.domainkey.dhngagtoz5n6777wkmvw6ll2aqlow4wpnwisycw6oabxgrxih5m6a.domains.proton.ch.",
	 ],
	 [
	   "protonmail2._domainkey",
	   "protonmail2.domainkey.dhngagtoz5n6777wkmvw6ll2aqlow4wpnwisycw6oabxgrxih5m6a.domains.proton.ch.",
	 ],
	 [
	   "protonmail3._domainkey",
	   "protonmail3.domainkey.dhngagtoz5n6777wkmvw6ll2aqlow4wpnwisycw6oabxgrxih5m6a.domains.proton.ch.",
	 ],
    ], 
    "noahhuppert.com": [
	 [
	   "protonmail._domainkey",
	   "protonmail.domainkey.d2i3l6setswma5tygpxpd7llkrjpntekxmytca5etovoacggdmrka.domains.proton.ch."
	 ],
	 [
	   "protonmail2._domainkey",
	   "protonmail2.domainkey.d2i3l6setswma5tygpxpd7llkrjpntekxmytca5etovoacggdmrka.domains.proton.ch."
	 ],
	 [
	   "protonmail3._domainkey",
	   "protonmail3.domainkey.d2i3l6setswma5tygpxpd7llkrjpntekxmytca5etovoacggdmrka.domains.proton.ch."
	 ],
    ],
    "goldblum.zone": [],
    "oliversgame.deals": [],
    "4e48.dev": [],
    "turtle.wiki": [],
  }
}

variable "dmarc" {
  type = map(string)
  description = "DMARC policies for domains."
  default = {
    "funkyboy.zone": "",
    "noahh.io": "v=DMARC1; p=none; rua=mailto:contact@noahh.io",
    "noahhuppert.com": "v=DMARC1; p=none; rua=mailto:contact@noahhuppert.com",
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

module "domains" {
  source = "../domain"
  for_each = toset(var.domains)

  name = each.key
  target = digitalocean_droplet.funkyboy_zone.ipv4_address
  spf = length(var.mx[each.key]) > 0 ? var.spf_email : var.spf_no_email
  keybase_verification = var.keybase_verification[each.key]
  mx = var.mx[each.key]
  dkim = var.dkim[each.key]
  dmarc = var.dmarc[each.key]
  protonmail_verification = var.protonmail_verification[each.key]
}
