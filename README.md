# HomeOps-as-Code
A GitOps appraoch to managing my homelab.

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

## Components
- Ansible playbooks for container deployments
- Terraform playbooks for hybrid infra provisioning
