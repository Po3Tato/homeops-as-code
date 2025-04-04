# List available Ansible commands
ansible:
    @echo "Available Ansible commands:"
    @echo ""
    @echo "System Updates:"
    @echo "  just update-prod-deb VAULT [LIMIT]   - Update Debian/Ubuntu production hosts"
    @echo "  just update-prod-rpm VAULT [LIMIT]   - Update RHEL/Rocky production hosts"
    @echo "  just update-prod VAULT               - Update all production hosts"
    @echo ""
    @echo "Docker Installation:"
    @echo "  just docker-install ENV VAULT        - Install Docker on environment"
    @echo "  just docker-status ENV               - Check Docker status on hosts"
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

update-prod-rpm VAULT LIMIT='':
    cd ansible && ansible-playbook playbooks/system/srv_update.yml \
    -i inventory/infra/prod/hosts.yml \
    --tags rpm_srv \
    $([ ! -z "{{LIMIT}}" ] && echo "--limit {{LIMIT}}") \
    --extra-vars "@vaults/{{VAULT}}" \
    --ask-vault-pass

# Update All Production Hosts
update-prod VAULT:
    cd ansible && ansible-playbook playbooks/system/srv_update.yml \
    -i inventory/infra/prod/hosts.yml \
    --extra-vars "@vaults/{{VAULT}}" \
    --ask-vault-pass

# Docker Installation
docker-install ENV VAULT:
    cd ansible && ansible-playbook playbooks/docker/docker_install.yml \
    -i inventory/infra/{{ENV}}/hosts.yml \
    --extra-vars "@vaults/{{VAULT}}" \
    --ask-vault-pass

# Check Docker Status
docker-status ENV:
    cd ansible && ansible all -i inventory/infra/{{ENV}}/hosts.yml -m shell -a "systemctl status docker"