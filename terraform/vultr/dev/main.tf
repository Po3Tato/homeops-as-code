terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.25.0"
    }
  }
}

provider "vultr" {
  api_key     = var.api_key
  rate_limit  = 100
  retry_limit = 3
}

resource "vultr_startup_script" "vm_script" {
  name   = var.script_name
  script = base64encode(file("${path.module}/startup-script.sh"))
  type   = "boot"
}

module "vultr_instance" {
  source = "../modules/vultr_vm"
  script_id         = vultr_startup_script.vm_script.id
  instance_plan     = "vhf-1c-2gb"
  region            = "ord"
  os_id             = 2284
  environment       = "dev"
  ssh_key_name      = "musoadmin-dev"
  firewall_group_id = "dfa09148-2204-405e-8914-01c70adfbfd7"
  tags              = ["DEV", "CI/CD", "opentofu"]
  hostname_prefix   = "test-v1.0"
  hostname_format   = "%s-%s-vps%02d-srv"

  instances = {
    "instance1" = {
      number = 1,
      plan   = "vhf-1c-2gb",
      region = "ord"
    }
    "instance2" = {
      number = 2,
      plan   = "vhf-1c-2gb",
      region = "ord"
    }
  }
}