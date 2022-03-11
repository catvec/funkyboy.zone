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
  type = list(string)
  description = "The mail servers to publish, must contain 2 servers, one primary and one secondary (Optional)."
  default = []

  validation {
    condition = length(var.mx) == 2 || length(var.mx) == 0
    error_message = "The mx value must contain 2 elements [primary mx, secondary mx] or be empty to disable email DNS records."
  }
}

variable "dkim" {
  type = list(tuple([string, string]))
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
}

variable "protonmail_verification" {
  type = string
  description = "Protonmail domain ownership verification (Optional)."
  default = ""
}
