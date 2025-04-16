variable "api_key" {
  description = "Vultr API key"
  type        = string
  sensitive   = true
}

variable "script_name" {
  description = "Name of the startup script"
  type        = string
}

variable "tailscale_auth_key" {
  description = "Tailscale authentication key"
  type        = string
  sensitive   = true
}

variable "user" {
  description = "Admin username"
  type        = string
  default     = "musoadmin"
}
