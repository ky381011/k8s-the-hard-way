variable "node_name" {
  description = "A string containing the cluster node name"
  type        = string
  default     = null
  nullable    = false
}

variable "vm_id" {
  description = "A string containing the VM ID for the LXC container"
  type        = string
  default     = null
  nullable    = true
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

variable "operating_system" {
  description = "An object containing the operating system configuration for the LXC container"
  type = object({
    template_file_id = string
    type             = string
  })
  default  = null
  nullable = false

  validation {
    condition     = var.operating_system != null
    error_message = "The operating system configuration must be provided."
  }
}

# Exactly one rootfs per container; use mount_point blocks for additional volumes.
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

variable "memory" {
  description = "An object containing the memory configuration for the LXC container"
  type = object({
    dedicated = number
    swap      = number
  })
  default = null

  validation {
    condition = (
      var.memory == null ||
      (var.memory.dedicated > 0 && var.memory.swap >= 0)
    )
    error_message = "'dedicated' must be greater than 0 and 'swap' must be 0 or greater."
  }
}

variable "network_interface" {
  description = "A map of network interface configurations for the LXC container"
  type = map(object({
    name    = string
    bridge  = string
    address = string
    gateway = string
    vlan_id = number
  }))
}
