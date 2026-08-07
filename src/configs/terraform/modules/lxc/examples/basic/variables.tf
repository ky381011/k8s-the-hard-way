variable "proxmox_endpoint" {
  description = "The URL of the Proxmox API endpoint"
  type        = string
}

variable "proxmox_username" {
  description = "The username for Proxmox API authentication"
  type        = string
}

variable "proxmox_password" {
  description = "The password for Proxmox API authentication"
  type        = string
  sensitive   = true
}

variable "node_name" {
  description = "The Proxmox cluster node to deploy the container on"
  type        = string
  default     = "pve"
}

variable "vm_id" {
  description = "The VM ID for the LXC container"
  type        = string
  default     = null
}

variable "hostname" {
  description = "The hostname for the LXC container"
  type        = string
  default     = "basic-lxc"
}

variable "ip_address" {
  description = "The IPv4 address with prefix length (e.g. 192.168.1.100/24)"
  type        = string
}

variable "gateway" {
  description = "The default gateway for the container"
  type        = string
}

variable "template_file_id" {
  description = "The Proxmox content ID of the OS template"
  type        = string
  default     = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
}

variable "datastore_id" {
  description = "The Proxmox datastore to use for the root disk"
  type        = string
  default     = "local-lvm"
}

variable "disk_size" {
  description = "The root disk size in GiB"
  type        = number
  default     = 8
}

variable "bridge" {
  description = "The Linux bridge to attach the network interface to"
  type        = string
  default     = "vmbr0"
}
