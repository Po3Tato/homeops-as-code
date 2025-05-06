output "vm_id" {
  description = "ID of the created VM"
  value       = proxmox_virtual_environment_vm.vm.vm_id
}

output "vm_name" {
  description = "Name of the created VM"
  value       = proxmox_virtual_environment_vm.vm.name
}
# Below can be removed
output "vm_ips" {
  description = "All non-loopback IPv4 addresses of the VM"
  value = flatten([
    for iface_ips in proxmox_virtual_environment_vm.vm.ipv4_addresses : [
      for ip in iface_ips : ip 
      if ip != "127.0.0.1" 
    ]
  ])
}
