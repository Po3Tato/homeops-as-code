locals {
  node_names = toset([for k, v in var.vms : v.node_name])
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  for_each     = local.node_names
  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key
  url          = var.ubuntu_cloud_image_url
  overwrite    = true
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  for_each     = var.vms
  content_type = "snippets"
  datastore_id = "local"
  node_name    = each.value.node_name
  source_raw {
    data = templatefile(
      "${path.module}/cloud-init/${lookup(each.value, "cloud_init_template", var.default_cloud_init)}",
      {
        hostname          = each.value.name
        username          = lookup(each.value, "username", var.default_username)
        ssh_key           = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0DaqyLC8EieXS6mqCPAfjCMzyzg9soZB68f5tMTNW+jlnCtcrLL2JdvvG8IzNxFG1ICIOkJHL8q9t78xNPu8kRxX4V9gzDtJCjH4J4MDpc45efRpWgAsAtczeG4QJ705At0JbLsIZJ8QbEgVBQ9+Da5jAuFXRSq0boVSVUw+lLwdh/5AzO6uRlQcKRfC2QfjgPulqCIGFw9uZA5bdWO+qSiYFOVzbF2OIfyZrnP68n1EVlcYxpJkN9C8Cnwq7fx/oHPlDiFFm/k3PnyKYlJR4mpfgPs7GsZU+BmSWwEElGD8i+M8MG1bFw2PIpbbq3NbR90zJYIvQAkkuJJgKRIk1bbBAv6/16ZpZ0u+1gOUJKDLP4XOoM55WiAIMK4fqeTfKX8iEabNOfEyIPTxUvvJt/p+GXFEfH3NpMJUTLs4sVhmTPEt6ljA1zLKSsWRwnG36F1DPM+qokKvauaYwSzj1Z7OoiZmVCUdspfWUIvLj0Km2ddncDdrP0fTPeAKJHmRrL7NVSWOcpHRaipQf/ebw53F7ZH2Xme5zgUCs4Gy9FpQRyht0QrWTU8oKovRaSPS7Rp5gApq73UIS2IZzdMLnduGHVc89bvL7K3lItpxmloZZ3DvhwcVGz0hIEeV0rF/iQUFIToQn6y57Ojy9DoSGXQIZgBXDCcFQVwwKg8+OlQ== ashing-srv"
        tailscale_authkey = var.tailscale_authkey
      }
    )
    file_name = "user-data-${each.value.name}.yaml"
  }
}

module "persistent_disks" {
  source      = "../modules/disk"
  for_each    = { for k, v in var.vms : k => v if length(v.persistent_disks) > 0 }
  disk_config = {
    name        = each.value.name
    vm_id       = each.value.vm_id
    node_name   = each.value.node_name
    datastore_id = var.datastore_disk
    disks       = each.value.persistent_disks
  }
}

module "vms" {
  source          = "../modules/vm"
  for_each        = var.vms
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
  hostpci          = lookup(each.value, "hostpci", [])
  viommu          = lookup(each.value, "viommu", var.default_viommu)
  disk_size       = each.value.disk_size
  node_name       = each.value.node_name
  datastore_disk  = var.datastore_disk
  network_bridge  = var.network_bridge
  cloud_image_id  = proxmox_virtual_environment_download_file.ubuntu_cloud_image[each.value.node_name].id
  cloud_config_id = proxmox_virtual_environment_file.cloud_config[each.key].id
  vlan_id         = each.value.vlan_id
  username        = lookup(each.value, "username", var.default_username)
  agent_enabled   = var.agent_enabled
  vm_reboot       = lookup(each.value, "vm_reboot", var.vm_reboot)
  tags            = concat(["opentofu"], lookup(each.value, "tags", []))
  persistent_disk_vm = length(lookup(each.value, "persistent_disks", [])) > 0 ? module.persistent_disks[each.key].disk_container : null
}
