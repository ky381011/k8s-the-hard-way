resource "proxmox_lxc" "this" {
  // Required parameters
  target_node = var.target_node

  // Optional parameters
  hostname    = var.hostname
}
