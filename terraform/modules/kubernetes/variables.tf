variable "name" {
  type = string
  description = "Name of the Kubernetes cluster"
}

variable "region" {
  type = string
  description = "Identifier of DigitalOcean region in which the cluster will be created"

  validation {
    condition = contains([ "nyc1", "nyc3", "ams3", "sfo3", "sgp1", "lon1", "fra1", "tor1", "blr1" ], var.region)
    error_message = "Must be one of the following:  [ nyc1, nyc3, ams3, sfo3, sgp1, lon1, fra1, tor1, blr1 ] (Populated from: https://docs.digitalocean.com/products/platform/availability-matrix/#other-product-availability)"
  }
}

variable "kubernetes_version" {
  type = string
  description = "Kubernetes cluster version"

  validation {
    condition = contains([ "1.22.8-do.1", "1.21.11-do.1" ], var.kubernetes_version)
    error_message = "Must be on of: [ 1.22.8-do.1, 1.21.11-do.1 ] (Populated from the `doctl kubernetes options versions` command)"
  }
}

variable "node_pools" {
  type = list(object({
    name = string
    size = string
    node_count = number
  }))
  description = "Worker node pool definitions"
}

variable "maintenance" {
  type = object({
    day = string
    start_time = string
  })
  description = "When the cluster should be taken down for maintenance by Digital Ocean"

  validation {
    condition = contains(
	 ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday", "any"], var.maintenance.day) && can(regex("^[0-9]{2}:[0-9]{2}$", var.maintenance.start_time))
    error_message = "day must be one of: [ monday, tuesday, wednesday, thursday, friday, saturday, sunday, any] and start_time must be in UTC in the format: HH:MM (strftime format: %k:%M)"
  }
}
