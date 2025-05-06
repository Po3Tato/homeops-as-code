# Proxmox VM Deployment with Terraform

This Terraform configuration automates the configuration of Proxmox VMs using cloud-init.

## Folder Structure

```
terraform/proxmox/
├── dev/
│   ├── main.tf              # Main configuration file
│   ├── variables.tf         # Variable definitions
│   ├── outputs.tf           # Output definitions
│   ├── provider.tf          # Provider configuration
│   └── terraform.tfvars.example  # Example variables file
└── modules/
    └── vm/
        ├── main.tf          # VM module configuration
        └── outputs.tf       # VM module outputs
```

## Prerequisites

1. Proxmox VE server
2. OpenTofu/Terraform installed on your local machine
4. Proxmox API token
5. Tailscale account and authkey (if using Tailscale)

## Initial Setup

1. Copy terraform.tfvars.example to terraform.tfvars:
   ```
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit terraform.tfvars with your specific configuration:
   * Set your Proxmox node details
   * Configure VM specifications (CPU, memory, disk)
   * Add your Proxmox API endpoint and token
   * Set your Tailscale authkey
   * Adjust VM networking settings

## Architecture & Design

The configuration follows a modular approach for better maintainability and reusability. With time, more modules will be added (LXC and SDWAN):

### VM Module (`/modules/vm`)
* Reusable VM configuration template
* Handles core VM resource creation
* Manages networking, CPU, memory, and disk configurations
* Provides standardized outputs for VM information

## Usage

1. Initialize Terraform:
   ```
   terraform init
   ```

2. Review planned changes:
   ```
   terraform plan
   ```

3. Apply configuration:
   ```
   terraform apply
   ```

## Outputs

* `vm_ids`: IDs of created VMs
* `vm_names`: Names of created VMs
* `vm_ips`: IP addresses of created VMs

## Notes

* VMs use DHCP networking
* Default VM specs adjustable in variables
* VMs tagged with "opentofu"
* QEMU guest agent enabled by default
* Includes hotplug support for CPU and memory