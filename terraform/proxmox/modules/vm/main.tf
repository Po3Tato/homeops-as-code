terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
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
  default     = ["opentofu", "musosys"]
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
  machine = var.viommu != "" ? "${var.machine_type},viommu=${var.viommu}" : var.machine_type
  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }
  cpu {
    cores = var.cpu_cores
    type  = var.cpu_type
  }
  memory {
    dedicated = var.memory
    floating  = var.memory
  }
  disk {
    datastore_id = var.datastore_disk
    file_id      = var.cloud_image_id
    interface    = "scsi0"
    size         = var.disk_size
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
    vlan_id = var.vlan_id
  }
  operating_system {
    type = "l26"
  }
  serial_device {}
}
