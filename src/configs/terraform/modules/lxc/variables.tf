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
