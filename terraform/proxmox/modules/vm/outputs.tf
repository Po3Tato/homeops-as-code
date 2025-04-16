output "vm_ids" {
  description = "IDs of the created VMs"
  value       = proxmox_virtual_environment_vm.vm[*].vm_id
}

output "vm_names" {
  description = "Names of the created VMs"
  value       = proxmox_virtual_environment_vm.vm[*].name
}

output "vm_ips" {
  description = "All non-loopback IPv4 addresses of each VM"
  value = [
    for vm in proxmox_virtual_environment_vm.vm : flatten([
      for iface_ips in vm.ipv4_addresses : [
        for ip in iface_ips : ip
        if ip != "127.0.0.1"  # This hides the local ip and beautifies IP display
      ]
    ])
  ]
}
