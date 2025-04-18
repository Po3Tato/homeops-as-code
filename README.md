# HomeOps-as-Code

A GitOps approach to managing my homelab infrastructure with enterprise-grade practices.

## Overview

This repository contains infrastructure as code configurations for managing my entire homelab ecosystem across multiple environments and networks. It combines modern DevOps tools and practices to create a reproducible, version-controlled infrastructure.

## Overview

| Feature | Tool | Method | Status |
| :--- | :--- | :--- | :---: |
| Deploy VMs from templates on Proxmox | just | cli | ✅ |
| Deploy VMs on Proxmox  | just | cli | ✅ |
| Ansible Restructure  | Ansible | just | ✅ |
| Configure/baseline VMs and other servers | OpenTofu | just | ✅ |
| Deploy Docker workloads | Docker Compose | Jenkins | ❌ |
| Configure/bootstrap Kubernetes nodes | just | taloscli | ❌ |
| Deploy Kubernetes workloads | Talos | FluxCD | ❌ |

#### Key
| Icon | Meaning |
| --- | --- | 
| ❌ | Not started |
| 🚧 | In-Progress |
| ✅ | Complete |

## Architecture
- **On-premises**: Proxmox Hypervisor
- **Cloud providers**: AWS, DigitalOcean, and Vultr for external services and redundancy
- **Networking**: Tailscale for secure zero-trust mesh networking
- **Configuration management**: Ansible for consistent server configuration
- **Infrastructure provisioning**: OpenTofu (Terraform) for declarative infrastructure
- **Container orchestration**: Docker Compose (working to move over to Kubernetes)

## Components

### Ansible
- Playbooks for system updates and maintenance
- Docker installation and configuration
- Network and firewall configuration
- Role-based configuration for different server types

### Terraform/OpenTofu
Multiple provider configurations:
- **Proxmox**: Local VM management with cloud-init integration
- **AWS**: EC2 instance deployment with security groups
- **DigitalOcean**: Droplet management with firewalls
- **Vultr**: Multi-region instance deployment

### Just Command Runner
The repository uses [just](https://github.com/casey/just) as a command runner for simplified operations:
