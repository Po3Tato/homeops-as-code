terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.25.0"
    }
  }
}

data "vultr_ssh_key" "key_pair" {
  filter {
    name   = "name"
    values = [var.ssh_key_name]
  }
}

resource "vultr_instance" "instance" {
  for_each = var.instances
  plan                = lookup(each.value, "plan", var.instance_plan)
  region              = lookup(each.value, "region", var.region)
  os_id               = var.os_id
  label               = "${var.hostname_prefix}-${var.environment}-${each.value.number}"
  tags                = var.tags
  hostname            = format(var.hostname_format,
                             var.hostname_prefix,
                             var.environment,
                             each.value.number)
  script_id           = var.script_id
  ssh_key_ids         = [data.vultr_ssh_key.key_pair.id]
  enable_ipv6         = false
  disable_public_ipv4 = false
  backups             = "enabled"
  backups_schedule {
    type = "weekly"
  }
  ddos_protection     = false
  activation_email    = false
  firewall_group_id   = var.firewall_group_id
}