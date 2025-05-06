variable "vms" {
  description = "Map of VMs with their configurations"
  type = map(object({
    node_name           = string
    name                = string
    vm_id               = number
    cpu_cores           = number
    memory              = number
    disk_size           = number
    vlan_id             = number
    username            = optional(string)
    vm_reboot           = optional(bool)
    cloud_init_template = optional(string)
    cpu_type            = optional(string)
    hotplug_cpu         = optional(bool)
    hotplug_memory      = optional(bool)
    max_cpu             = optional(number)
    max_memory          = optional(number)
    machine_type        = optional(string)
    viommu              = optional(string)
    tags                = optional(list(string), [])
    persistent_disks    = optional(list(object({
      id                = string
      size              = number
      datastore_id      = optional(string)
    })), [])
    hostpci = optional(list(object({
      device = string
      mapping     = string
      pcie   = optional(bool)
      rombar = optional(bool)
      xvga   = optional(bool)
    })), [])
  }))
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
  default     = "vmbr0"
}

variable "virtual_environment_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "virtual_environment_api_token" {
  description = "Proxmox API token"
  type        = string
  sensitive   = true
}

variable "ubuntu_cloud_image_url" {
  description = "URL for Ubuntu cloud image"
  type        = string
  default     = "https://cloud-images.ubuntu.com/minimal/daily/noble/current/noble-minimal-cloudimg-amd64.img"
}

variable "vm_reboot" {
  description = "Whether to reboot the VM"
  type        = bool
  default     = false
}

variable "agent_enabled" {
  description = "Whether to enable the QEMU guest agent"
  type        = bool
  default     = true
}

variable "tailscale_authkey" {
  description = "Tailscale authentication key"
  type        = string
}

variable "default_username" {
  description = "Default username for VMs if not specified"
  type        = string
  default     = "ubuntu"
}

variable "default_cloud_init" {
  description = "Default cloud-init template to use if not specified"
  type        = string
  default     = "user-data.yaml"
}

variable "default_cpu_type" {
  description = "Default CPU type to use if not specified"
  type        = string
  default     = "x86-64-v2-AES"
}

variable "default_hotplug_cpu" {
  description = "Default setting for CPU hotplug"
  type        = bool
  default     = false
}

variable "default_hotplug_memory" {
  description = "Default setting for memory hotplug"
  type        = bool
  default     = false
}

variable "default_max_cpu" {
  description = "Default maximum CPU cores for hotplug"
  type        = number
  default     = 4
}

variable "default_max_memory" {
  description = "Default maximum memory in MB for hotplug"
  type        = number
  default     = 8192
}

variable "default_machine_type" {
  description = "Default machine type for VMs"
  type        = string
  default     = "i440fx"
}

variable "default_viommu" {
  description = "Default vIOMMU setting (empty string for disabled)"
  type        = string
  default     = ""
}
