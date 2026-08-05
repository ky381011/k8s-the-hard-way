# Tests that the module creates a container with the minimum required configuration.
mock_provider "proxmox" {}

run "creates_container_with_required_fields" {
  variables {
    node_name = "pve"
    vm_id     = "100"

    initialization = {
      hostname = "test-lxc"
      ip_config = [{
        address = "192.168.1.100/24"
        gateway = "192.168.1.1"
      }]
    }

    operating_system = {
      template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
      type             = "debian"
    }

    disk = {
      datastore_id = "local-lvm"
      size         = 8
    }

    network_interface = {
      eth0 = {
        name    = "eth0"
        bridge  = "vmbr0"
        address = "192.168.1.100/24"
        gateway = "192.168.1.1"
        vlan_id = 0
      }
    }
  }

  assert {
    condition     = proxmox_virtual_environment_container.this.node_name == "pve"
    error_message = "node_name must match the provided value."
  }

  assert {
    condition     = proxmox_virtual_environment_container.this.initialization[0].hostname == "test-lxc"
    error_message = "hostname must match the provided value."
  }
}

run "creates_container_with_optional_memory" {
  variables {
    node_name = "pve"
    vm_id     = "101"

    initialization = {
      hostname = "test-lxc-memory"
      ip_config = [{
        address = "192.168.1.101/24"
        gateway = "192.168.1.1"
      }]
    }

    operating_system = {
      template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
      type             = "debian"
    }

    disk = {
      datastore_id = "local-lvm"
      size         = 8
    }

    memory = {
      dedicated = 1024
      swap      = 512
    }

    network_interface = {
      eth0 = {
        name    = "eth0"
        bridge  = "vmbr0"
        address = "192.168.1.101/24"
        gateway = "192.168.1.1"
        vlan_id = 0
      }
    }
  }

  assert {
    condition     = proxmox_virtual_environment_container.this.memory[0].dedicated == 1024
    error_message = "dedicated memory must match the provided value."
  }

  assert {
    condition     = proxmox_virtual_environment_container.this.memory[0].swap == 512
    error_message = "swap memory must match the provided value."
  }
}

run "creates_container_with_mount_point" {
  variables {
    node_name = "pve"
    vm_id     = "102"

    initialization = {
      hostname = "test-lxc-mount"
      ip_config = [{
        address = "192.168.1.102/24"
        gateway = "192.168.1.1"
      }]
    }

    operating_system = {
      template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
      type             = "debian"
    }

    disk = {
      datastore_id = "local-lvm"
      size         = 8
    }

    network_interface = {
      eth0 = {
        name    = "eth0"
        bridge  = "vmbr0"
        address = "192.168.1.102/24"
        gateway = "192.168.1.1"
        vlan_id = 0
      }
    }

    mount_point = [{
      volume = "local-lvm"
      path   = "/mnt/data"
      size   = 20
    }]
  }

  assert {
    condition     = proxmox_virtual_environment_container.this.mount_point[0].path == "/mnt/data"
    error_message = "mount_point path must match the provided value."
  }
}

run "creates_container_with_multiple_network_interfaces" {
  variables {
    node_name = "pve"
    vm_id     = "103"

    initialization = {
      hostname = "test-lxc-multi-net"
      ip_config = [
        {
          address = "192.168.1.103/24"
          gateway = "192.168.1.1"
        },
        {
          address = "10.0.0.103/24"
          gateway = "10.0.0.1"
        },
      ]
    }

    operating_system = {
      template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
      type             = "debian"
    }

    disk = {
      datastore_id = "local-lvm"
      size         = 8
    }

    network_interface = {
      eth0 = {
        name    = "eth0"
        bridge  = "vmbr0"
        address = "192.168.1.103/24"
        gateway = "192.168.1.1"
        vlan_id = 0
      }
      eth1 = {
        name    = "eth1"
        bridge  = "vmbr1"
        address = "10.0.0.103/24"
        gateway = "10.0.0.1"
        vlan_id = 100
      }
    }
  }

  assert {
    condition     = length(proxmox_virtual_environment_container.this.network_interface) == 2
    error_message = "Two network interfaces must be created."
  }
}
