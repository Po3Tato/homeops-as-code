# List available Ansible commands
ansible:
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

# Update Prod Hosts (Distribution Specific)
update-prod-deb:
    @ansible-playbook ansible/playbooks/system/srv_update.yml -i inventory/infra/prod/hosts.yml --tags deb_srv

update-prod-rpm:
    @ansible-playbook ansible/playbooks/system/srv_update.yml -i inventory/infra/prod/hosts.yml --tags rpm_srv

# Update All Production Hosts
update-prod:
    @ansible-playbook ansible/playbooks/system/srv_update.yml -i inventory/infra/prod/hosts.yml

# Update Any Environment with Optional Flags
update ENV *FLAGS='':
    @ansible-playbook ansible/playbooks/system/srv_update.yml -i inventory/infra/{{ENV}}/hosts.yml {{FLAGS}}

# Docker Installation
docker-install ENV:
    @ansible-playbook ansible/playbooks/docker/docker_install.yml -i inventory/infra/{{ENV}}/hosts.yml

# Check Docker Status
docker-status ENV:
    @ansible all -i inventory/infra/{{ENV}}/hosts.yml -m shell -a "systemctl status docker"

# List All Inventory Hosts
ansible-list ENV:
    @ansible-inventory -i inventory/infra/{{ENV}}/hosts.yml --list

# Show Update Status Only
update-status ENV:
    @ansible-playbook ansible/playbooks/system/srv_update.yml -i inventory/infra/{{ENV}}/hosts.yml --tags status