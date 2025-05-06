#!/bin/bash
# Exit on any error
set -e
# Check if environment argument is provided
if [ -z "$1" ]; then
    echo "Error: Environment argument is required (dev|prod|vps)"
    exit 1
fi

ENV=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ANSIBLE_DIR="${PROJECT_ROOT}/ansible/inventory/infra/${ENV}"
TERRAFORM_DIR="${PROJECT_ROOT}/terraform/proxmox/${ENV}"
INVENTORY_FILE="${ANSIBLE_DIR}/hosts.yml"
BACKUP_FILE="${ANSIBLE_DIR}/hosts.yml.bak"
TEMP_FILE="${ANSIBLE_DIR}/hosts.yml.temp"
# Function to display error messages
error() {
    echo "ERROR: $1" >&2
    exit 1
}
# Function to display info messages
info() {
    echo "INFO: $1"
}
# Check for required commands
command -v jq >/dev/null 2>&1 || error "jq is required but not installed. Please install jq first (apt install jq)"
command -v tofu >/dev/null 2>&1 || error "OpenTofu (tofu) is required but not installed"
# Change to terraform directory
info "Changing to Terraform directory: ${TERRAFORM_DIR}"
cd "${TERRAFORM_DIR}" || error "Failed to change to terraform directory"
# Create backup of existing inventory
if [ -f "${INVENTORY_FILE}" ]; then
    info "Creating backup of current inventory file..."
    cp "${INVENTORY_FILE}" "${BACKUP_FILE}" || error "Failed to create inventory backup"
    cp "${INVENTORY_FILE}" "${TEMP_FILE}"
else
    # Create new inventory file with basic structure
    cat > "${TEMP_FILE}" << EOF
---
all:
  hosts:
  children:
    deb_srv:
      hosts:
EOF
fi
# Get VM names from Terraform output
VM_NAMES=$(tofu output -json vm_names | jq -r '.[]')
# Function to add or update VM in inventory
update_vm_entry() {
    local name=$1
    local temp_file=$2
    
    if grep -q "^[[:space:]]*${name}:" "${temp_file}"; then
        # Update existing VM entry
        info "Updating existing VM: ${name}"
        sed -i "/^[[:space:]]*${name}:/,/^[[:space:]]*[a-zA-Z0-9_-]*:/c\  ${name}:\n    ansible_host: mn-dev-dock\n    ansible_os_family: Debian" "${temp_file}"
    else
        # Add new VM entry in the hosts section
        info "Adding new VM: ${name}"
        sed -i "/^[[:space:]]*hosts:/a\  ${name}:\n    ansible_host: mn-dev-dock\n    ansible_os_family: Debian" "${temp_file}"
        
        # Also add to deb_srv hosts
        sed -i "/deb_srv:/a\        ${name}:" "${temp_file}"
    fi
}
# Process each VM
echo "$VM_NAMES" | while read -r name; do
    update_vm_entry "$name" "${TEMP_FILE}"
done

mv "${TEMP_FILE}" "${INVENTORY_FILE}"

info "Successfully updated inventory file at: ${INVENTORY_FILE}"
info "Backup saved as: ${BACKUP_FILE}"

echo "Updated inventory contents:"
echo "-------------------------"
cat "${INVENTORY_FILE}"

if [ -f "${BACKUP_FILE}" ]; then
    echo -e "\nChanges made:"
    echo "-------------"
    diff "${BACKUP_FILE}" "${INVENTORY_FILE}" || true
fi