# Tests that variable validation rules correctly reject invalid inputs.
mock_provider "proxmox" {}

# --- initialization ---

run "fails_when_initialization_is_null" {
  expect_failures = [var.initialization]

  variables {
    node_name      = "pve"
    initialization = null

    operating_system = {
      template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
      type             = "debian"
    }

    disk = {
      datastore_id = "local-lvm"
      size         = 8
    }

    network_interface = {}
  }
}

run "fails_when_hostname_is_empty" {
  expect_failures = [var.initialization]

  variables {
    node_name = "pve"

    initialization = {
      hostname  = "   "
      ip_config = [{ address = "192.168.1.100/24", gateway = "192.168.1.1" }]
    }

    operating_system = {
      template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
      type             = "debian"
    }

    disk = {
      datastore_id = "local-lvm"
      size         = 8
    }

    network_interface = {}
  }
}

run "fails_when_ip_config_is_empty_list" {
  expect_failures = [var.initialization]

  variables {
    node_name = "pve"

    initialization = {
      hostname  = "test-lxc"
      ip_config = []
    }

    operating_system = {
      template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
      type             = "debian"
    }

    disk = {
      datastore_id = "local-lvm"
      size         = 8
    }

    network_interface = {}
  }
}

run "fails_when_ip_config_address_is_empty" {
  expect_failures = [var.initialization]

  variables {
    node_name = "pve"

    initialization = {
      hostname  = "test-lxc"
      ip_config = [{ address = "", gateway = "192.168.1.1" }]
    }

    operating_system = {
      template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
      type             = "debian"
    }

    disk = {
      datastore_id = "local-lvm"
      size         = 8
    }

    network_interface = {}
  }
}

run "fails_when_ip_config_gateway_is_empty" {
  expect_failures = [var.initialization]

  variables {
    node_name = "pve"

    initialization = {
      hostname  = "test-lxc"
      ip_config = [{ address = "192.168.1.100/24", gateway = "" }]
    }

    operating_system = {
      template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
      type             = "debian"
    }

    disk = {
      datastore_id = "local-lvm"
      size         = 8
    }

    network_interface = {}
  }
}

# --- operating_system ---

run "fails_when_operating_system_is_null" {
  expect_failures = [var.operating_system]

  variables {
    node_name = "pve"

    initialization = {
      hostname  = "test-lxc"
      ip_config = [{ address = "192.168.1.100/24", gateway = "192.168.1.1" }]
    }

    operating_system = null

    disk = {
      datastore_id = "local-lvm"
      size         = 8
    }

    network_interface = {}
  }
}

# --- disk ---

run "fails_when_disk_is_null" {
  expect_failures = [var.disk]

  variables {
    node_name = "pve"

    initialization = {
      hostname  = "test-lxc"
      ip_config = [{ address = "192.168.1.100/24", gateway = "192.168.1.1" }]
    }

    operating_system = {
      template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
      type             = "debian"
    }

    disk = null

    network_interface = {}
  }
}

run "fails_when_disk_size_is_zero" {
  expect_failures = [var.disk]

  variables {
    node_name = "pve"

    initialization = {
      hostname  = "test-lxc"
      ip_config = [{ address = "192.168.1.100/24", gateway = "192.168.1.1" }]
    }

    operating_system = {
      template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
      type             = "debian"
    }

    disk = {
      datastore_id = "local-lvm"
      size         = 0
    }

    network_interface = {}
  }
}

run "fails_when_disk_datastore_id_is_empty" {
  expect_failures = [var.disk]

  variables {
    node_name = "pve"

    initialization = {
      hostname  = "test-lxc"
      ip_config = [{ address = "192.168.1.100/24", gateway = "192.168.1.1" }]
    }

    operating_system = {
      template_file_id = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
      type             = "debian"
    }

    disk = {
      datastore_id = "   "
      size         = 8
    }

    network_interface = {}
  }
}

# --- memory ---

run "fails_when_memory_dedicated_is_zero" {
  expect_failures = [var.memory]

  variables {
    node_name = "pve"

    initialization = {
      hostname  = "test-lxc"
      ip_config = [{ address = "192.168.1.100/24", gateway = "192.168.1.1" }]
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
      dedicated = 0
      swap      = 0
    }

    network_interface = {}
  }
}

run "fails_when_memory_swap_is_negative" {
  expect_failures = [var.memory]

  variables {
    node_name = "pve"

    initialization = {
      hostname  = "test-lxc"
      ip_config = [{ address = "192.168.1.100/24", gateway = "192.168.1.1" }]
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
      dedicated = 512
      swap      = -1
    }

    network_interface = {}
  }
}
