terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 2.9"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.provider_configs.pm_api_url
  pm_api_token_id = var.provider_configs.pm_api_token_id
  pm_api_token    = var.provider_configs.pm_api_token
  pm_tls_insecure = var.provider_configs.pm_tls_insecure
}
