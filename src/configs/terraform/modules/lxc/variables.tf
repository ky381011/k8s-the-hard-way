variable "node_name" {
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
