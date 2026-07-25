terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.111.1"
    }
  }
}

provider "proxmox" {
  endpoint = var.provider_config.endpoint

  # APIトークン認証（推奨）
  api_token = var.provider_config.api_token

  # 自己署名証明書の場合
  insecure = var.provider_config.insecure
}
