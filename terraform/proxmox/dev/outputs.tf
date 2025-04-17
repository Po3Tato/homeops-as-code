output "vm_ids" {
  description = "IDs of the created VMs"
  value       = module.vms.vm_ids
}

output "vm_names" {
  description = "Names of the created VMs"
  value       = module.vms.vm_names
}

output "vm_ips" {
  description = "IP addresses of the created VMs"
  value       = module.vms.vm_ips
}
