terraform {
  required_providers {
    vultr = {
      source = "vultr/vultr"
      version = "2.25.0"
    }
  }
}

provider "vultr" {
  api_key = var.api_key
  rate_limit = 100
  retry_limit = 3
}
data "vultr_ssh_key" "key_pair" {
  filter {
    name = "name"
    values = ["default-user"]
  }
}

resource "vultr_instance" "prod_instance" {
	plan = "vhf-1c-2gb"
	region = "nyc" # can be a variable
	os_id = 2284 # can be a variable
	label = "prod" # change to dynamic naming
	tags = ["PROD", "CICD", "OpenTofu"]
	hostname = "srv-prod"
	ssh_key_ids = [data.vultr_ssh_key.key_pair.id]
	enable_ipv6 = false
	disable_public_ipv4 = false
	backups = "enabled"
	backups_schedule {
	        type = "weekly"
	}
	ddos_protection = false
	activation_email = false
  firewall_group_id = "dfa09148-2204-405e-8914-01c70adfbfd7"
}
