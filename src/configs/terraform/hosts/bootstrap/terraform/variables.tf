variable "provider_configs" {
  type = object({
    endpoint = string
    api_token = string
    insecure = bool
  })
  default = {
    endpoint = null
    api_token = null
    insecure = false
  }
  description = "Proxmox provider configuration"
}
