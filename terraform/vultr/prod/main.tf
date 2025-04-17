terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.26.0"
    }
  }
}

provider "vultr" {
  api_key = var.vultr_api_key
}

module "vultr_instances" {
  source = "../modules/vultr-instance"
  vultr_api_key       = var.vultr_api_key
  username            = var.username
  hostname            = var.hostname
  tailscale_auth_key  = var.tailscale_auth_key
  ssh_key_name        = var.ssh_key_name
  ssh_pub_key         = var.ssh_pub_key
  region              = var.region
  os_id               = var.os_id
  firewall_group_id   = var.firewall_group_id
  backups_enabled     = var.backups_enabled
  backup_schedule     = var.backup_schedule
  script_name         = var.script_name
  instances           = var.instances
}
