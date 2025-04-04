# Show all available Ansible commands
@ansible:
    @#!/usr/bin/env sh
    @cat << 'END'
Available Ansible commands:

System Updates:
  just update-prod-deb     - Update Debian/Ubuntu production hosts
  just update-prod-rpm     - Update RHEL/Rocky production hosts
  just update-prod         - Update all production hosts
  just update ENV [FLAGS]  - Update hosts with optional flags

Docker Installation:
  just docker-install ENV  - Install Docker on specified environment
  just docker-status ENV   - Check Docker status on hosts

Environments (ENV):
  prod | dev | vps

Examples:
  just update prod
  just update dev '--tags deb_srv'
  just docker-install prod
END

# Update Prod Hosts (Distribution Specific)
@update-prod-deb:
    @ansible-playbook playbooks/system/srv_update.yml -i inventory/infra/prod/hosts.yml --tags deb_srv

@update-prod-rpm:
    @ansible-playbook playbooks/system/srv_update.yml -i inventory/infra/prod/hosts.yml --tags rpm_srv

# Update All Production Hosts
@update-prod:
    @ansible-playbook playbooks/system/srv_update.yml -i inventory/infra/prod/hosts.yml

# Update Any Environment with Optional Flags
@update ENV *FLAGS='':
    @ansible-playbook playbooks/system/srv_update.yml -i inventory/infra/{{ENV}}/hosts.yml {{FLAGS}}

# Docker Installation
@docker-install ENV:
    @ansible-playbook playbooks/docker/docker_install.yml -i inventory/infra/{{ENV}}/hosts.yml

# Check Docker Status
@docker-status ENV:
    @ansible all -i inventory/infra/{{ENV}}/hosts.yml -m shell -a "systemctl status docker"

# List All Inventory Hosts
@ansible-list ENV:
    @ansible-inventory -i inventory/infra/{{ENV}}/hosts.yml --list

# Show Update Status (only)
@update-status ENV:
    @ansible-playbook playbooks/system/srv_update.yml -i inventory/infra/{{ENV}}/hosts.yml --tags status
