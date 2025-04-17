resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.node_name
  url          = var.ubuntu_cloud_image_url
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  count = var.vm_count
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node_name
  source_raw {
    data = templatefile("${path.module}/cloud-init/user-data.yaml", {
      hostname = "${var.base_name}-srv${format("%02d", count.index + 1)}"
      username = var.vm_username
      ssh_key  = file("~/.ssh/id_rsa.pub")
      tailscale_authkey = var.tailscale_authkey
    })
    file_name = "user-data-${var.base_name}-srv${format("%02d", count.index + 1)}.yaml"
  }
}

module "vms" {
  source          = "../modules/vm"
  base_name       = var.base_name
  vm_count        = var.vm_count
  vm_id_base      = var.vm_id_base
  cpu_cores       = var.cpu_cores
  memory          = var.memory
  disk_size       = var.disk_size
  node_name       = var.node_name
  datastore_disk  = var.datastore_disk
  network_bridge  = var.network_bridge
  cloud_image_id  = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
  cloud_config_id = proxmox_virtual_environment_file.cloud_config[*].id
  vlan_id         = var.vlan_id
  vm_username     = var.vm_username
  agent_enabled   = var.agent_enabled
}
