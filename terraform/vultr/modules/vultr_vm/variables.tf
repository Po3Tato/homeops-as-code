variable "api_key" {
  description = "Vultr API key"
  type        = string
  sensitive   = true
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "instances" {
  description = "Map of instances to create with their specific configs"
  type = map(object({
    number = number
    plan   = optional(string)
    region = optional(string)
  }))
  default = {}
}

variable "hostname_format" {
  description = "Format for the hostname. Use %d for the instance number"
  type        = string
  default     = "%s-%s-vps%02d-srv"  # prefix-env-vps01-srv, ...-vps02-...etc
}

variable "instance_plan" {
  description = "Vultr instance plan"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "os_id" {
  description = "OS ID"
  type        = number
}

variable "environment" {
  description = "Environment (dev/prod)"
  type        = string
}

variable "ssh_key_name" {
  description = "SSH key id"
  type        = string
}

variable "firewall_group_id" {
  description = "Firewall Group ID"
  type        = string
}

variable "tags" {
  description = "Tags"
  type        = list(string)
  default     = []
}

variable "hostname_prefix" {
  description = "Prefix for the hostname"
  type        = string
  default     = "vps-test"
}
