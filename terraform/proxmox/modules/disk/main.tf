terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

variable "disk_config" {
  description = "Configuration for persistent disk VM"
  type = object({
    name        = string
    vm_id       = number
    node_name   = string
    datastore_id = string
    disks       = list(object({
      id         = string
      size       = number
      datastore_id = optional(string)
    }))
  })
}

resource "proxmox_virtual_environment_vm" "disk_container" {
  name        = "${var.disk_config.name}-disk-container"
  description = "Disk container managed by OpenTofu - DO NOT START"
  tags        = ["opentofu", "disk-container"]
  node_name   = var.disk_config.node_name
  vm_id       = var.disk_config.vm_id + 9000  # high ID range for disk containers
  started     = false
  on_boot     = false
  cpu {
    cores    = 1
    sockets  = 1
    type     = "host"
  }
  memory {
    dedicated = 512
  }
  dynamic "disk" {
    for_each = { for idx, disk in var.disk_config.disks : idx => disk }
    content {
      datastore_id = disk.value.datastore_id != null ? disk.value.datastore_id : var.disk_config.datastore_id
      interface    = "scsi${disk.key}"
      size         = disk.value.size
      file_format  = "raw"
    }
  }
}
