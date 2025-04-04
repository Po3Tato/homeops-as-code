# `just ansible` to See all commands
@ansible:
    #!/usr/bin/env sh
    cat << 'END'
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

# Update Prod Hosts(Distribution Specific)
@update-prod-deb:
    ansible-playbook playbooks/system/srv_update.yml -i inventory/infra/prod/hosts.yml --tags deb_srv

@update-prod-rpm:
    ansible-playbook playbooks/system/srv_update.yml -i inventory/infra/prod/hosts.yml --tags rpm_srv

# Update All (Doesn't matter Distribution)
@update-prod:
    ansible-playbook playbooks/system/srv_update.yml -i inventory/infra/prod/hosts.yml

# Allow tag to be passed as an argument
@update ENV *FLAGS='':
    ansible-playbook playbooks/system/srv_update.yml -i inventory/infra/{{ENV}}/hosts.yml {{FLAGS}}

# Docker commands
@docker-install ENV:
    ansible-playbook playbooks/docker/docker_install.yml -i inventory/infra/{{ENV}}/hosts.yml

@docker-status ENV:
    ansible all -i inventory/infra/{{ENV}}/hosts.yml -m shell -a "systemctl status docker"

# List all inventory hosts
@ansible-list ENV:
    ansible-inventory -i inventory/infra/{{ENV}}/hosts.yml --list

# Only show system update status
@update-status ENV:
    ansible-playbook playbooks/system/srv_update.yml -i inventory/infra/{{ENV}}/hosts.yml --tags status