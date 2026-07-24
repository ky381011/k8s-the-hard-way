resource "proxmox_lxc" "this" {
  target_node = var.target_node

  hostname    = var.hostname
  ostemplate  = var.ostemplate

  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
  }
}
