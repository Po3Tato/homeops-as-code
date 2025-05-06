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
    @echo "Installation:"
    @echo "  just install SERVICE ENV VAULT [LIMIT]    - Install any service"
    @echo ""
    @echo "System Updates:"
    @echo "  just update-prod-deb VAULT [LIMIT]   - Update Debian/Ubuntu production hosts"
    @echo "  just update-prod-rpm VAULT [LIMIT]   - Update RHEL/Rocky production hosts"
    @echo "  just update-dev VAULT [LIMIT]        - Update Dev host"
    @echo "  just update-all VAULT               - Update all host across infra"
    @echo ""
    @echo "Available services:"
    @echo "  docker      - Install Docker containers engine"
    @echo "  fossorial   - Install Fossorial Pangolin application"
    @echo "  firewall    - Install and configure Firewalld"
    @echo "  base-pkg    - Install base packages"
    @echo ""
    @echo "Parameters:"
    @echo "  SERVICE   : Service to install (docker | fossorial | firewall | base-pkg)"
    @echo "  ENV       : prod | dev | vps"
    @echo "  VAULT     : Vault file name from ansible/vaults/ (e.g., prod.yml)"
    @echo "  LIMIT     : Host group or server (e.g., deb_srv or prod-ext-srv)"
    @echo ""
    @echo "Examples:"
    @echo "  just install docker dev dev.yml                    # Install Docker on dev"
    @echo "  just install fossorial prod prod.yml               # Install Fossorial on prod"
    @echo "  just install firewall dev dev.yml example-dev-srv  # Install firewall on specific host"
    @echo "  just install base-pkg dev dev.yml                  # Install base packages on dev"

# Install any service by name
install SERVICE ENV VAULT LIMIT='':
    #!/usr/bin/env bash
    cd ansible
    case "{{SERVICE}}" in
        docker)
            playbook="docker/docker_install.yml"
            ;;
        fossorial)
            playbook="docker/pangolin_install.yml"
            ;;
        firewall)
            playbook="system/base_firewall.yml"
            ;;
        base-pkg)
            playbook="system/base_pkg.yml"
            ;;
        *)
            echo "Error: Unknown service '{{SERVICE}}'"
            echo "Available services: docker, fossorial, firewall, base-pkg"
            exit 1
            ;;
    esac
    
    ansible-playbook playbooks/$playbook \
        -i inventory/infra/{{ENV}}/hosts.yml \
        --extra-vars "@vaults/{{VAULT}}" \
        --ask-vault-pass \
        $([ ! -z "{{LIMIT}}" ] && echo "--limit {{LIMIT}}") \
        -vv

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

# Docker Installation (deprecated - use 'just install docker' instead)
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

# Firewall Installation (deprecated - use 'just install firewall' instead)
firewall-install ENV VAULT LIMIT='':
    cd ansible && ansible-playbook playbooks/system/base_firewall.yml \
    -i inventory/infra/{{ENV}}/hosts.yml \
    --tags dev_srv \
    $([ ! -z "{{LIMIT}}" ] && echo "--limit {{LIMIT}}") \
    --extra-vars "@vaults/{{VAULT}}" \
    --ask-vault-pass -vvv

# Helper function to run any playbook (optional advanced usage)
_run-playbook PLAYBOOK ENV VAULT LIMIT='' TAGS='':
    cd ansible && ansible-playbook playbooks/{{PLAYBOOK}} \
    -i inventory/infra/{{ENV}}/hosts.yml \
    $([ ! -z "{{LIMIT}}" ] && echo "--limit {{LIMIT}}") \
    $([ ! -z "{{TAGS}}" ] && echo "--tags {{TAGS}}") \
    --extra-vars "@vaults/{{VAULT}}" \
    --ask-vault-pass