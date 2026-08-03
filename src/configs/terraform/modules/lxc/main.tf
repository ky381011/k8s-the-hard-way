resource "proxmox_virtual_environment_container" "this" {
  node_name = var.node_name
  vm_id     = var.vm_id

  initialization {
    hostname = var.initialization.hostname

    dynamic "ip_config" {
      for_each = var.initialization.ip_config
      iterator = ip_config
      content {
        ipv4 {
          address = ip_config.value.address
          gateway = ip_config.value.gateway
        }
      }
    }
  }

  operating_system {
    template_file_id = var.operating_system.template_file_id
    type             = var.operating_system.type
  }

  disk {
    datastore_id = var.disk.datastore_id
    size         = var.disk.size
  }

  dynamic "memory" {
    for_each = var.memory != null ? [var.memory] : []
    content {
      dedicated = memory.value.dedicated
      swap      = memory.value.swap
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interface
    iterator = network_interface
    content {
      name    = network_interface.value.name
      bridge  = network_interface.value.bridge
      vlan_id = network_interface.value.vlan_id
    }
  }
}
