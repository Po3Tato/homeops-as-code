output "instance_ips" {
  description = "The IPs of the created instances"
  value       = module.vultr_instances.instance_ips
}

output "instance_hostnames" {
  description = "The hostnames of the created instances"
  value       = module.vultr_instances.instance_hostnames
}
