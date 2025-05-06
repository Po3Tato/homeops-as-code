terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

variable "persistent_disk_vm" {
  description = "Reference to a persistent disk VM"
  type        = any
  default     = null
}

variable "name" {
  description = "Name for the VM"
  type        = string
}

variable "vm_id" {
  description = "VM ID"
  type        = number
}

variable "cpu_cores" {
  description = "Number of CPU cores for the VM"
  type        = number
}

variable "cpu_type" {
  description = "CPU type for the VM"
  type        = string
  default     = "host"
}

variable "memory" {
  description = "Memory in MB for the VM"
  type        = number
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
}

variable "node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "datastore_disk" {
  description = "Datastore for VM disks"
  type        = string
}

variable "network_bridge" {
  description = "Network bridge to use"
  type        = string
}

variable "vlan_id" {
  description = "VLAN ID for network interface"
  type        = number
  default     = null
}

variable "cloud_image_id" {
  description = "ID of the cloud image to use"
  type        = string
}

variable "cloud_config_id" {
  description = "ID of the cloud config to use"
  type        = string
}

variable "username" {
  description = "Username for VM access"
  type        = string
}

variable "agent_enabled" {
  description = "Enable the QEMU guest agent"
  type        = bool
  default     = false
}

variable "vm_reboot" {
  description = "Whether to reboot the VM"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to assign to the VM"
  type        = list(string)
  default     = ["opentofu"]
}

variable "hotplug_cpu" {
  description = "Whether to enable CPU hotplug"
  type        = bool
  default     = false
}

variable "hotplug_memory" {
  description = "Whether to enable memory hotplug"
  type        = bool
  default     = false
}

variable "max_cpu" {
  description = "Maximum number of CPU cores for hotplug"
  type        = number
  default     = null
}

variable "max_memory" {
  description = "Maximum memory in MB for hotplug"
  type        = number
  default     = null
}

variable "machine_type" {
  description = "Machine type for the VM"
  type        = string
  default     = "i440fx"
}

variable "viommu" {
  description = "VIOMMU type (e.g., 'intel' for Intel vIOMMU)"
  type        = string
  default     = ""
}

variable "hostpci" {
  description = "List of host PCI devices to pass through to the VM"
  type = list(object({
    device  = string
    mapping      = string
    pcie    = optional(bool, false)
  }))
  default = []
}

resource "proxmox_virtual_environment_vm" "vm" {
  name        = var.name
  description = "Managed by OpenTofu"
  tags        = var.tags
  node_name   = var.node_name
  vm_id       = var.vm_id
  agent {
    enabled = var.agent_enabled
  }
  reboot = var.vm_reboot
  stop_on_destroy = true
  machine = local.safe_viommu != "" ? "${local.safe_machine_type},viommu=${local.safe_viommu}" : local.safe_machine_type
  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }
  cpu {
    sockets = 1
    cores       = var.cpu_cores
    type       = var.cpu_type
    numa        = local.safe_hotplug_cpu
    hotplugged = local.safe_hotplug_cpu ? (local.safe_max_cpu - var.cpu_cores) : 0
    flags = local.safe_hotplug_cpu ? ["+pcid", "+aes"] : ["+aes"]
    units = 1024
}
  # Memory configuration with ballooning support - hotplug enabled
  memory {
    dedicated = var.memory
    floating  = local.safe_hotplug_memory ? var.memory : 0
    shared    = 0
}
  disk {
    datastore_id = var.datastore_disk
    file_id      = var.cloud_image_id
    interface    = "scsi0"
    size         = var.disk_size
    ssd          = true
  }
  dynamic "disk" {
    for_each = var.persistent_disk_vm != null ? { for idx, disk in var.persistent_disk_vm.disk : idx => disk } : {}
    content {
      datastore_id      = disk.value["datastore_id"]
      path_in_datastore = disk.value["path_in_datastore"]
      file_format       = disk.value["file_format"]
      size              = disk.value["size"]
      interface         = "scsi${disk.key + 1}"
    }
  }
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_account {
      username = var.username
    }
    user_data_file_id = var.cloud_config_id
  }
  network_device {
    bridge = var.network_bridge
    model  = "virtio"
    vlan_id = var.vlan_id != null ? var.vlan_id : 0
  }
  operating_system {
    type = "l26"
  }
  serial_device {}
  dynamic "hostpci" {
    for_each = var.hostpci
    content {
      device  = hostpci.value.device
      mapping      = hostpci.value.mapping
      pcie    = lookup(hostpci.value, "pcie", false)
      rombar  = lookup(hostpci.value, "rombar", true)
      xvga    = lookup(hostpci.value, "xvga", false)
    }
  }
}

locals {
  safe_hotplug_cpu = var.hotplug_cpu == null ? false : var.hotplug_cpu
  safe_hotplug_memory = var.hotplug_memory == null ? false : var.hotplug_memory
  safe_max_cpu = var.max_cpu == null ? var.cpu_cores : var.max_cpu
  safe_max_memory = var.max_memory == null ? var.memory : var.max_memory
  safe_machine_type = var.machine_type == null ? "pc" : var.machine_type
  safe_viommu = var.viommu == null ? "" : var.viommu
}
