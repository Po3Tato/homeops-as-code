terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.48.2"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "dev-ssh-key" {
  name = var.ssh_key_name
}

locals {
  user_data = templatefile("${path.module}/cloud-init.yml", {
    ts_auth  = var.ts_auth
    user = var.user
    ssh_key  = trimspace(data.digitalocean_ssh_key.dev-ssh-key.public_key)
  })
}

module "prod_droplets" {
  source = "../modules/droplet"

  environment   = "prod"
  droplet_count = var.droplet_count
  region        = var.region
  ssh_key_id    = data.digitalocean_ssh_key.dev-ssh-key.id
  user_data     = local.user_data
  project_id    = var.project_id
  droplet_tags  = var.droplet_tags
}

module "prod_waf" {
  source = "../modules/https-waf"

  environment  = "prod"
  droplet_ids = module.prod_droplets.droplet_ids

  depends_on = [module.prod_droplets]
}

output "public_ips" {
  value       = module.prod_droplets.public_ips
  description = "Public IP"
}
