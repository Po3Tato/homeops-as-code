# Vultr VM Deployment with Terraform

Terraform configuration to automate the deployment of VMs on Vultr's cloud platform.

## Folder Structure

```
vultr/
├── dev/
│   ├── main.tf        # My development environment configuration
│   └── variables.tf   # Development variables
├── prod/
│   ├── main.tf        # Production environment configuration
│   └── variables.tf   # Production variables
└── modules/
    └── vultr_vm/
        ├── main.tf      # VM module configuration
        ├── variables.tf # Module variables
        └── outputs.tf   # Module outputs
```

## Prerequisites

1. Vultr account
2. Vultr API key
3. SSH key uploaded to Vultr
4. OpenTofu or Terraform installed locally
5. Existing firewall group in Vultr

## Initial Setup

1. Configure your Vultr API key in variables
2. Ensure your SSH key is uploaded to Vultr
3. Note your firewall group ID
4. Create environment-specific configurations

## My Architecture & Design

### VM Module (`/modules/vultr_vm`)
- Reusable instance configuration
- Supports multiple instance deployment
- Handles SSH key management
- Configures backups and security
- Standardized outputs for instance information

## Key Features I've Implemented
- Weekly backups enabled
- Firewall group assignment
- Flexible instance sizing
- Automated hostname generation

## Outputs
- `instance_ips_list`: Main IP addresses of instances
- `instance_ids_list`: Instance IDs
- `instance_labels_list`: Instance labels
- `instance_hostnames_list`: Instance hostnames

## Notes
- My go to VPS is the `vhf-1c-2gb` plan by default (High-Frequency VPS)
- I plan to add a WAF playbook in future updates