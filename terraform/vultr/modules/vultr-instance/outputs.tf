output "instance_ips" {
  description = "The IPs of the created instances"
  value = {
    for idx, instance in vultr_instance.instances : instance.hostname => instance.main_ip
  }
}

output "instance_hostnames" {
  description = "The hostnames of the created instances"
  value = {
    for idx, instance in vultr_instance.instances : instance.hostname => instance.hostname
  }
}
