output "disk_container" {
  description = "The disk container VM resource"
  value       = proxmox_virtual_environment_vm.disk_container
}

output "vm_id" {
  description = "ID of the disk container VM"
  value       = proxmox_virtual_environment_vm.disk_container.vm_id
}

output "disks" {
  description = "Disk configurations of the container VM"
  value       = proxmox_virtual_environment_vm.disk_container.disk
}
