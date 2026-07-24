variable "target_node" {
  description = "A string containing the cluster node name"
  type        = string
  default     = null
  nullable    = false
}

variable "hostname" {
  description = "A string containing the hostname of the LXC container"
  type        = string
  default     = null
  nullable    = false
}

variable "ostemplate" {
  description = "A string containing the Proxmox LXC template name"
  type        = string
  default     = null
  nullable    = false
}

variable "rootfs" {
  description = "A map containing the rootfs configuration for the LXC container"
  type = object({
    storage = string
    size    = string
  })
  default = null

  validation {
    condition     = var.rootfs != null 
    error_message = "In order to create an LXC container, the rootfs configuration must be provided."
  }

  validation {
    condition = (
    !can(var.rootfs.storage) ||
      (
        trimspace(var.rootfs.storage) != "" &&
        trimspace(var.rootfs.size) != ""
      )
    )
    error_message = "Both 'storage' and 'size' must be provided in the rootfs configuration."
  }
}
