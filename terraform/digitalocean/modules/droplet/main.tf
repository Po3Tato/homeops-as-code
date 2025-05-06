# Base droplet config
resource "digitalocean_droplet" "base_vm" {
  count      = var.droplet_count
  image      = "ubuntu-24-04-x64"
  name       = "${var.environment}-ext0${count.index + 1}-${var.region}"
  region     = var.region
  size       = "s-1vcpu-512mb-10gb"
  monitoring = true
  ssh_keys   = [var.ssh_key_id]
  user_data  = var.user_data
  tags       = concat([var.environment], var.droplet_tags)
}

resource "digitalocean_project_resources" "project_assignment" {
  project   = var.project_id
  resources = flatten([digitalocean_droplet.base_vm[*].urn])
}