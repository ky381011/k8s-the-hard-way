resource "proxmox_virtual_environment_container" "this" {
  node_name = var.node_name

  initialization {
    hostname = var.hostname

    dynamic "ip_config" {
      for_each = var.network
      content {
        ipv4 {
          address = ip_config.value.address
          gateway = ip_config.value.gateway
        }
      }
    }
  }

  operating_system {
    template_file_id = var.template_file_id
  }

  disk {
    datastore_id = var.disk.datastore_id
    size         = var.disk.size
  }

  dynamic "network_interface" {
    for_each = var.network
    content {
      name    = network_interface.value.name
      bridge  = network_interface.value.bridge
      vlan_id = network_interface.value.vlan_id
    }
  }
}
