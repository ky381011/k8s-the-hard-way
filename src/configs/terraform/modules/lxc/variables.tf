variable "node_name" {
  description = "A string containing the cluster node name"
  type        = string
  default     = null
  nullable    = false
}

variable "initialization" {
  description = "An object containing the initialization configuration for the LXC container"
  type = object({
    hostname = string
    ip_config = list(object({
      address = string
      gateway = string
    }))
  })
  default  = null
  nullable = false

  # Ensures the initialization configuration is provided when creating an LXC container.
  validation {
    condition     = var.initialization != null
    error_message = "In order to create an LXC container, the initialization configuration must be provided."
  }

  # Ensures the hostname is not an empty or whitespace-only string.
  validation {
    condition = (
      !can(var.initialization.hostname) ||
      trimspace(var.initialization.hostname) != ""
    )
    error_message = "The 'hostname' must not be empty."
  }

  # Ensures at least one IP configuration entry is provided.
  validation {
    condition = (
      !can(var.initialization.ip_config) ||
      length(var.initialization.ip_config) > 0
    )
    error_message = "At least one 'ip_config' entry must be provided."
  }

  # Ensures each IP configuration entry has non-empty 'address' and 'gateway' values.
  validation {
    condition = (
      !can(var.initialization.ip_config) ||
      alltrue([
        for cfg in var.initialization.ip_config :
        trimspace(cfg.address) != "" && trimspace(cfg.gateway) != ""
      ])
    )
    error_message = "Each 'ip_config' entry must have non-empty 'address' and 'gateway'."
  }
}

variable "template_file_id" {
  description = "A string containing the Proxmox LXC template file ID"
  type        = string
  default     = null
  nullable    = false
}

variable "disk" {
  description = "A map containing the disk configuration for the LXC container"
  type = object({
    datastore_id = string
    size         = number
  })
  default = null

  validation {
    condition     = var.disk != null
    error_message = "In order to create an LXC container, the disk configuration must be provided."
  }

  validation {
    condition = (
      !can(var.disk.datastore_id) ||
      (
        trimspace(var.disk.datastore_id) != "" &&
        var.disk.size > 0
      )
    )
    error_message = "Both 'datastore_id' and 'size' must be provided in the disk configuration."
  }
}

variable "network" {
  description = "A map of network interface configurations for the LXC container"
  type = map(object({
    name    = string
    bridge  = string
    address = string
    gateway = string
    vlan_id = number
  }))
}
