# Vultr VM Deployment with Terraform

This Terraform configuration automates the deployment of VMs on Vultr's cloud platform.

## Folder Structure
vultr/
├── dev/
│   ├── main.tf           # Development environment configuration
│   └── variables.tf      # Development variables
├── prod/
│   ├── main.tf           # Production environment configuration 
│   └── variables.tf      # Production variables
└── modules/
    └── vultr_vm/
        ├── main.tf       # VM module configuration
        ├── variables.tf   # Module variables
        └── outputs.tf    # Module outputs

## Prerequisites
1. Vultr account
2. Vultr API key
3. SSH key uploaded to Vultr (referenced as "musoadmin-dev")
4. Terraform installed locally
5. Existing firewall group in Vultr

## Initial Setup
1. Configure your Vultr API key in variables
2. Ensure your SSH key is uploaded to Vultr
3. Note your firewall group ID
4. Create environment-specific configurations

## Architecture & Design
The configuration uses different approaches for dev and prod environments:

1. Development Environment (/dev):
   - Uses modular approach for multiple instances
   - Supports dynamic instance creation via map variables
   - Includes startup script functionality
   - Flexible hostname formatting
   - Configurable instance specifications per deployment

2. Production Environment (/prod):
   - Direct instance configuration
   - Simplified, static configuration
   - Focused on single instance deployment
   - Hardened security settings

3. VM Module (/modules/vultr_vm):
   - Reusable instance configuration
   - Supports multiple instance deployment
   - Handles SSH key management
   - Configures backups and security
   - Standardized outputs for instance information

Key Features:
- Weekly backups enabled
- IPv6 disabled by default
- Firewall group integration
- Custom tagging support
- Flexible instance sizing
- Automated hostname generation

## Outputs
- instance_ips_list: Main IP addresses of instances
- instance_ids_list: Instance IDs
- instance_labels_list: Instance labels
- instance_hostnames_list: Instance hostnames

## Notes
- Uses vhf-1c-2gb plan by default. HighFrequency
- Includes CI/CD and OpenTofu tags
- Backups enabled by default
- IPv6 disabled by default