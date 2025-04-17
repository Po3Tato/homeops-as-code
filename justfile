# Show all available command categories
all:
    @echo "Available command categories:"
    @echo ""
    @echo "  just ansible    - Show Ansible-related commands"
    @echo "  just system     - Show System management commands"
    @echo ""
    @echo "Run the specific category to see detailed commands"

# System management commands
system:
    @echo "Available System commands:"
    @echo ""
    @echo "Infrastructure Management:"
    @echo "  just add-vms ENV                    - Add VMs from tofu output to inventory"
    @echo ""
    @echo "Parameters:"
    @echo "  ENV   : prod | dev | vps"
    @echo ""
    @echo "Examples:"
    @echo "  just add-vms dev                    # Add VMs to dev inventory"
    @echo "  just add-vms prod                   # Add VMs to prod inventory"

# Add VMs to ansible inventory
add-vms env="dev":
    sudo ./scripts/add_vm_inventory.sh {{env}}

# Ansible commands menu
ansible:
    @echo "Available Ansible commands:"
    @echo ""
    @echo "System Updates:"
    @echo "  just update-prod-deb VAULT [LIMIT]   - Update Debian/Ubuntu production hosts"
    @echo "  just update-prod-rpm VAULT [LIMIT]   - Update RHEL/Rocky production hosts"
    @echo "  just update-dev VAULT [LIMIT]        - Update Dev host"
    @echo "  just update-all VAULT               - Update all host across infra"
    @echo ""
    @echo "Docker Installation [dev_srv ONLY]:"
    @echo "  just docker-install ENV VAULT [LIMIT]       - Install Docker on environment"
    @echo "  just docker-status ENV               - Check Docker status on hosts"
    @echo ""
    @echo "Firewalld and Tailscale Setup [dev_srv ONLY]:"
    @echo "  just firewall-install ENV VAULT [LIMIT]        - Install Firewalld and configure to work with Tailscale"
    @echo ""
    @echo "Parameters:"
    @echo "  ENV   : prod | dev | vps"
    @echo "  VAULT : Vault file name from ansible/vaults/ (e.g., prod.yml)"
    @echo "  LIMIT : Host group or server (e.g., deb_srv or prod-ext-srv)"
    @echo ""
    @echo "Examples:"
    @echo "  just update-prod-deb prod.yml deb_srv        # Update all Debian servers"
    @echo "  just update-prod-deb prod.yml prod-ext-srv   # Update specific server"
    @echo "  just update-prod prod.yml                    # Update all servers"

# Update Prod Hosts (Distribution Specific)
update-prod-deb VAULT LIMIT='':
    cd ansible && ansible-playbook playbooks/system/srv_update.yml \
    -i inventory/infra/prod/hosts.yml \
    --tags deb_srv \
    $([ ! -z "{{LIMIT}}" ] && echo "--limit {{LIMIT}}") \
    --extra-vars "@vaults/{{VAULT}}" \
    --ask-vault-pass

update-dev VAULT LIMIT='':
    cd ansible && ansible-playbook playbooks/system/srv_update.yml \
    -i inventory/infra/dev/hosts.yml \
    $([ ! -z "{{LIMIT}}" ] && echo "--limit {{LIMIT}}") \
    --extra-vars "@vaults/{{VAULT}}" \
    --ask-vault-pass

update-prod-rpm VAULT LIMIT='':
    cd ansible && ansible-playbook playbooks/system/srv_update.yml \
    -i inventory/infra/prod/hosts.yml \
    --tags rpm_srv \
    $([ ! -z "{{LIMIT}}" ] && echo "--limit {{LIMIT}}") \
    --extra-vars "@vaults/{{VAULT}}" \
    --ask-vault-pass

# Update All Production Hosts
INVENTORY_DIR := "inventory/infra"
update-all VAULT:
    cd ansible && ansible-playbook playbooks/system/srv_update.yml \
    -i {{INVENTORY_DIR}}/prod/hosts.yml \
    -i {{INVENTORY_DIR}}/dev/hosts.yml \
    -i {{INVENTORY_DIR}}/vps/hosts.yml \
    --extra-vars "@vaults/{{VAULT}}" \
    --ask-vault-pass

# Docker Installation
docker-install ENV VAULT LIMIT='':
    cd ansible && ansible-playbook playbooks/docker/docker_install.yml \
    -i inventory/infra/{{ENV}}/hosts.yml \
    --tags dev_srv \
    $([ ! -z "{{LIMIT}}" ] && echo "--limit {{LIMIT}}") \
    --extra-vars "@vaults/{{VAULT}}" \
    --ask-vault-pass

# Check Docker Status
docker-status ENV VAULT:
    cd ansible && ansible all -i inventory/infra/{{ENV}}/hosts.yml --extra-vars "@vaults/{{VAULT}}" --ask-vault-pass -m shell -a "docker --version"

# Firewall Installation
firewall-install ENV VAULT LIMIT='':
    cd ansible && ansible-playbook playbooks/system/base_firewall.yml \
    -i inventory/infra/{{ENV}}/hosts.yml \
    --tags dev_srv \
    $([ ! -z "{{LIMIT}}" ] && echo "--limit {{LIMIT}}") \
    --extra-vars "@vaults/{{VAULT}}" \
    --ask-vault-pass -vvv
