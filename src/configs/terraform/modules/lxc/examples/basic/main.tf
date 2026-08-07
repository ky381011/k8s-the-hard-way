module "lxc" {
  source = "../../"

  node_name = var.node_name
  vm_id     = var.vm_id

  initialization = {
    hostname = var.hostname
    ip_config = [{
      address = var.ip_address
      gateway = var.gateway
    }]
  }

  operating_system = {
    template_file_id = var.template_file_id
    type             = "debian"
  }

  disk = {
    datastore_id = var.datastore_id
    size         = var.disk_size
  }

  memory = {
    dedicated = 1024
    swap      = 512
  }

  network_interface = {
    eth0 = {
      name    = "eth0"
      bridge  = var.bridge
      address = var.ip_address
      gateway = var.gateway
      vlan_id = 0
    }
  }
}
