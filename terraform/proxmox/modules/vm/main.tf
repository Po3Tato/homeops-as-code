terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

variable "base_name" {
  description = "Base name for the VMs"
  type        = string
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
}

variable "vm_id_base" {
  description = "Starting VM ID"
  type        = number
}

variable "cpu_cores" {
  description = "Number of CPU cores for each VM"
  type        = number
}

variable "memory" {
  description = "Memory in MB for each VM"
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
  type        = list(string)
}

variable "vm_username" {
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

resource "proxmox_virtual_environment_vm" "vm" {
  count       = var.vm_count
  name        = "${var.base_name}-srv${format("%02d", count.index + 1)}"
  description = "Managed by OpenTofu"
  tags        = ["opentofu", "musosys"]
  node_name   = var.node_name
  vm_id       = var.vm_id_base + count.index

  agent {
    enabled = var.agent_enabled # Enable after VM boot and agent installation
  }
  reboot = var.vm_reboot
  stop_on_destroy = true

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  cpu {
    cores = var.cpu_cores
    type  = "x86-64-v2-AES"
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
      username = var.vm_username
    }
    user_data_file_id = var.cloud_config_id[count.index]
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
