variable "environment" {
  description = "Environment name (prod/dev)"
  type        = string
}

variable "droplet_ids" {
  description = "List of droplet IDs to attach the firewall to"
  type        = list(string)
}
