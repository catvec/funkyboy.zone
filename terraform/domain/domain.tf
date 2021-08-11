# Variables
variable "name" {
  type = string
  description = "Fully qualified domain name."
}

variable "target" {
  type = string
  description = "Target IPv4 address to which all traffic will be sent."
}

variable "spf" {
  type = string
  description = "SPF policy to publish for the domain."
  default = "v=spf1 a ~all"
}

variable "keybase_verification" {
  type = string
  description = "Keybase verification text to host for DNS ownership proof (Optional)."
  default = ""
}

variable "mx" {
  type = list([string])
  description = "The mail servers to publish, must contain 2 servers, one primary and one secondary (Optional)."
  default = []

  validation {
    condition = length(var.mx) == 2 || length(var.mx) == 0
    error_message = "The mx value must contain 2 elements [primary mx, secondary mx] or be empty to disable email DNS records."
  }
}

variable "dkim" {
  type = list([tuple([string, string])])
  description = "The DKIM keys to publish, must contain 3 elements if mx is provided. Each element is a tuple of (dkim CNAME record name, value) (Optional)."
  default = []

  validation {
    condition = length(var.dkim) == 0 || length(var.dkim) == 3
    error_message = "The dkim value must have 3 elements if the mx value is provided."
  }
}

variable "dmarc" {
  type = string
  description = "The DMARC policy to public, required if mx is set (Optional)."
  default = ""

  validation {
    condition = length(var.mx) > 0 && length(var.dmarc) > 0
    error_message = "The dmarc value must be provided if the mx value is provided."
  }
}

# Content records
data "digitalocean_domain" "${domain}_domain" {
  name = domain
}

resource "digitalocean_record" "${domain}_wildcard" {
  domain = domain
  type = "A"
  ttl = "60" # seconds
  name = "*"
  value = var.target
}

resource "digitalocean_record" "${domain}_apex" {
  domain = domain
  type = "A"
  ttl = "60" # seconds
  name = "@"
  value = var.target
}

# Verification records
resource "digitalocean_record" "${domain}_spf" {
  domain = domain
  type = "TXT"
  ttl = "60" # seconds
  name = "@"
  value = var.spf
}


resource "digitalocean_record" "${domain}_keybase" {
  count = var.keybase_verification != "" ? 1 : 0
  domain = domain
  type = "TXT"
  ttl = "60" # seconds
  name = "_keybase"
  value = var.keybase_verification
}

resource "digitalocean_record" "${domain}_protonmail_mx10" {
  count = length(var.mx) > 0 ? 1 : 0
  domain = domain
  type = "TXT"
  ttl = "1800" # seconds
  name = "@"
  priority = 10
  value = var.mx[0]
}

resource "digitalocean_record" "${domain}_protonmail_mx20" {
  count = length(var.mx) > 0 ? 1 : 0
  domain = domain
  type = "TXT"
  ttl = "1800" # seconds
  name = "@"
  priority = 20
  value = var.mx[1]
}

resource "digitalocean_record" "${domain}_protonmail_dkim1" {
  count = length(var.mx) > 0 ? 1 : 0
  domain = domain
  type = "CNAME"
  ttl = "60" # seconds
  name = var.dkim[0][1]
  value = var.dkim[0][1]
}

resource "digitalocean_record" "${domain}_protonmail_dkim2" {
  count = length(var.mx) > 0 ? 1 : 0
  domain = domain
  type = "CNAME"
  ttl = "60" # seconds
  name = var.dkim[1][0]
  value = var.dkim[1][1]
}

resource "digitalocean_record" "${domain}_protonmail_dkim3" {
  count = length(var.mx) > 0 ? 1 : 0
  domain = domain
  type = "CNAME"
  ttl = "60" # seconds
  name = var.dkim[2][0]
  value = var.dkim[2][1]
}

resource "digitalocean_record" "${domain}_protonmail_dmarc" {
  count = length(var.mx) > 0 ? 1 : 0
  domain = domain
  type = "TXT"
  ttl = "3600" # seconds
  name = "_dmarc.${domain}"
  value = var.dmarc
}

