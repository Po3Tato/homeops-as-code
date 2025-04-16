output "instance_ips_list" {
  description = "The main IP addresses of the instances (as list)"
  value       = values(vultr_instance.instance)[*].main_ip
}

output "instance_ids_list" {
  description = "The IDs of the instances (as list)"
  value       = values(vultr_instance.instance)[*].id
}

output "instance_labels_list" {
  description = "The labels of the instances (as list)"
  value       = values(vultr_instance.instance)[*].label
}

output "instance_hostnames_list" {
  description = "The hostnames of the instances (as list)"
  value       = values(vultr_instance.instance)[*].hostname
}