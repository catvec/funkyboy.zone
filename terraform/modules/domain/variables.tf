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
  type = map(object({
    priority = number
    value = string
  }))
  description = "The mail servers to publish (Optional)."
  default = {}
}

variable "dkim" {
  type = map(object({
    name = string
    value = string
  }))
  description = "The DKIM keys to publish (Optional)."
  default = {}
}

variable "dmarc" {
  type = string
  description = "The DMARC policy to public, required if mx is set (Optional)."
  default = ""
}

variable "protonmail_verification" {
  type = string
  description = "Protonmail domain ownership verification (Optional)."
  default = ""
}

variable "google_verification" {
  type = string
  description = "Google workspaces domain ownership verification (Optional)."
  default = null
}