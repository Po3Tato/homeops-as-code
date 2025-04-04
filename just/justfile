# `just ansible` to See all commands
@ansible:
    @echo "Available Ansible commands:"
    @echo ""
    @echo "System Updates:"
    @echo "  just update-prod-deb     - Update Debian/Ubuntu production hosts"
    @echo "  just update-prod-rpm     - Update RHEL/Rocky production hosts"
    @echo "  just update-prod         - Update all production hosts"
    @echo "  just update ENV [FLAGS]  - Update hosts with optional flags"
    @echo ""
    @echo "Docker Installation:"
    @echo "  just docker-install ENV  - Install Docker on specified environment"
    @echo "  just docker-status ENV   - Check Docker status on hosts"
    @echo ""
    @echo "Environments (ENV):"
    @echo "  prod | dev | vps"
    @echo ""
    @echo "Examples:"
    @echo "  just update prod"
    @echo "  just update dev '--tags deb_srv'"
    @echo "  just docker-install prod"

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