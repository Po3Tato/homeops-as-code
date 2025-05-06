variable "ssh_key_name" {
  description = "SSH key in DigitalOcean"
  type        = string
}

variable "droplet_tags" {
  description = "List of tags to apply to the droplets"
  type        = list(string)
  default     = []
}

variable user {
  type        = string
  description = "admin user"
}

variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "ts_auth" {
  description = "Authentication token"
  type        = string
  sensitive   = true
}

variable "droplet_count" {
  description = "Number of droplets to create"
  type        = number
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
}

variable "project_id" {
  description = "DigitalOcean project ID"
  type        = string
}
