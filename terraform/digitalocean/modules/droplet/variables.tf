variable "environment" {
  description = "Environment name (prod/dev)"
  type        = string
}

variable "droplet_count" {
  description = "Number of droplets to create"
  type        = number
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
}

variable "ssh_key_id" {
  description = "SSH key ID for droplet access"
  type        = string
}

variable "user_data" {
  description = "Cloud-init user data"
  type        = string
}

variable "project_id" {
  description = "DigitalOcean project ID"
  type        = string
}

variable "droplet_tags" {
  description = "List of tags to apply to the droplets"
  type        = list(string)
  default     = []
}
