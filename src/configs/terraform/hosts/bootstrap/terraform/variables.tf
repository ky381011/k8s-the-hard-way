variable "provider_configs" {
  type = object({
    pm_api_url      = string
    pm_api_token_id = string
    pm_api_token    = string
    pm_tls_insecure = bool
  })
  default = {
    pm_api_url      = ""
    pm_api_token_id = ""
    pm_api_token    = ""
    pm_tls_insecure = false
  }
  description = "Proxmox provider configuration"
}
