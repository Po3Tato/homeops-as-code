variable "vultr_api_key" {
  description = "Vultr API key"
  type = string
  sensitive = true
}
variable "region" {
  description = "Default region for the instances"
  type = string
  default = "sea"
}
variable "os_id" {
  description = "OS ID for the instances"
  type = number
}
variable "ssh_key_name" {
  description = "SSH key name"
  type = string
}
variable "ssh_pub_key" {
  description = "SSH public key for user access"
  type = string
}
variable "firewall_group_id" {
  description = "Firewall Group ID"
  type = string
}
variable "username" {
  description = "Username to be created on the instances"
  type = string
}
variable "tailscale_auth_key" {
  description = "Tailscale authentication key"
  type = string
  sensitive = true
}
variable "backups_enabled" {
  description = "Enable or disable backups"
  type = string
  default = "disabled"
  validation {
    condition = contains(["enabled", "disabled"], var.backups_enabled)
    error_message = "Backup must be either 'enabled' or 'disabled'."
  }
}
variable "backup_schedule" {
  description = "Backup schedule configuration"
  type = object({
    type = string
  })
  default = null
}
variable "script_name" {
  description = "Name of the startup script"
  type = string
  default = "startup_script"
}
variable "hostname" {
  description = "Hostname for the instance"
  type = string
}
variable "instances" {
  description = "Map of instances to create with their specific configs"
  type = map(object({
    number = number
    plan = string
    region = string
    hostname = optional(string)
    tags = list(string)
  }))
}
