locals {
  instance_hostname_map = {
    for name, instance in var.instances : name => [
      for i in range(instance.number) : {
        hostname = instance.hostname != null ? instance.hostname : "${var.hostname}-${name}-${instance.region}"
        region   = instance.region
        plan     = instance.plan
        tags     = instance.tags
      }
    ]
  }
  
  flattened_instances = flatten([
    for name, configs in local.instance_hostname_map : configs
  ])
}

resource "vultr_instance" "instances" {
  count = length(local.flattened_instances)

  plan              = local.flattened_instances[count.index].plan
  region            = local.flattened_instances[count.index].region
  os_id             = var.os_id
  hostname          = local.flattened_instances[count.index].hostname
  label             = local.flattened_instances[count.index].hostname
  firewall_group_id = var.firewall_group_id
  tags              = local.flattened_instances[count.index].tags
  backups           = var.backups_enabled

  user_data = templatefile("${path.root}/scripts/startup_script.sh", {
    USERNAME          = var.username
    HOSTNAME          = local.flattened_instances[count.index].hostname
    SSH_KEY           = var.ssh_pub_key
    TAILSCALE_AUTH_KEY = var.tailscale_auth_key
  })
}
