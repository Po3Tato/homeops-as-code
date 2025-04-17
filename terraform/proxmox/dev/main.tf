resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.node_name
  url          = var.ubuntu_cloud_image_url
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  for_each = var.vms

  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.node_name
  source_raw {
    data = templatefile("${path.module}/cloud-init/${lookup(each.value, "cloud_init_template", var.default_cloud_init)}", {
      hostname          = each.value.name
      username          = lookup(each.value, "username", var.default_username)
      ssh_key           = file("~/.ssh/id_rsa.pub")
      tailscale_authkey = var.tailscale_authkey
    })
    file_name = "user-data-${each.value.name}.yaml"
  }
}

module "vms" {
  source = "../modules/vm"

  for_each = var.vms

  name            = each.value.name
  vm_id           = each.value.vm_id
  cpu_cores       = each.value.cpu_cores
  cpu_type        = lookup(each.value, "cpu_type", var.default_cpu_type)
  memory          = each.value.memory
  hotplug_cpu     = lookup(each.value, "hotplug_cpu", var.default_hotplug_cpu)
  hotplug_memory  = lookup(each.value, "hotplug_memory", var.default_hotplug_memory)
  max_cpu         = lookup(each.value, "max_cpu", var.default_max_cpu)
  max_memory      = lookup(each.value, "max_memory", var.default_max_memory)
  machine_type    = lookup(each.value, "machine_type", var.default_machine_type)
  viommu          = lookup(each.value, "viommu", var.default_viommu)
  disk_size       = each.value.disk_size
  node_name       = var.node_name
  datastore_disk  = var.datastore_disk
  network_bridge  = var.network_bridge
  cloud_image_id  = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
  cloud_config_id = proxmox_virtual_environment_file.cloud_config[each.key].id
  vlan_id         = each.value.vlan_id
  username        = lookup(each.value, "username", var.default_username)
  agent_enabled   = var.agent_enabled
  vm_reboot       = lookup(each.value, "vm_reboot", var.vm_reboot)
  tags            = concat(["opentofu"], lookup(each.value, "tags", []))
}
