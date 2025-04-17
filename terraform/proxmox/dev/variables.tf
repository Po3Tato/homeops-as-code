variable "base_name" {
  description = "Base name for the VMs"
  type        = string
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 1
}

variable "vm_id_base" {
  description = "Starting VM ID"
  type        = number
}

variable "cpu_cores" {
  description = "Number of CPU cores for each VM"
  type        = number
  default     = 1
}

variable "memory" {
  description = "Memory in MB for each VM"
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}

variable "datastore_disk" {
  description = "Datastore for VM disks"
  type        = string
}

variable "node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "network_bridge" {
  description = "Network bridge to use"
  type        = string
  default     = "vmbr0"
}

variable "vlan_id" {
  description = "VLAN ID for network interface"
  type        = number
  default     = null # non-VLAN networks
}

variable "vm_username" {
  description = "Default username for the VM"
  type        = string
  default     = "dev-ubuntu"
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

variable "use_meta_data" {
  description = "Whether to use meta data"
  type        = bool
  default     = true
}

variable "ubuntu_cloud_image_url" {
  description = "URL for Ubuntu cloud image"
  type        = string
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
variable "hotplug_cpu" {
  description = "Enable CPU hotplug"
  type        = bool
  default     = true
}

variable "hotplug_memory" {
  description = "Enable memory hotplug"
  type        = bool
  default     = true
}

variable "max_cpu" {
  description = "Maximum CPU cores for hotplug"
  type        = number
  default     = 1
}

variable "max_memory" {
  description = "Maximum memory in MB for hotplug"
  type        = number
  default     = 2048
}

variable "tailscale_authkey" {
  description = "Tailscale authentication key"
  type        = string
  sensitive   = true
}
