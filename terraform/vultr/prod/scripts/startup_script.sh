#!/bin/bash
# Set variables
USERNAME="${USERNAME}"
HOSTNAME="${HOSTNAME}"
SSH_KEY='${SSH_KEY}'
TAILSCALE_AUTH_KEY='${TAILSCALE_AUTH_KEY}'
# Update hostname
hostnamectl set-hostname $HOSTNAME
echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1 $HOSTNAME ${HOSTNAME}.mnlocal" >> /etc/hosts
# Update and upgrade packages
apt-get update
apt-get upgrade -y
# Install required packages
apt-get install -y \
    qemu-guest-agent \
    vim \
    curl \
    acpiphp \
    pci-hotplug
# Create user and configure sudo
useradd -m -s /bin/bash -G sudo $USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME
# Configure SSH
mkdir -p /home/$USERNAME/.ssh
echo "$SSH_KEY" > /home/$USERNAME/.ssh/authorized_keys
chmod 700 /home/$USERNAME/.ssh
chmod 600 /home/$USERNAME/.ssh/authorized_keys
chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
passwd -l $USERNAME
# Set timezone
timedatectl set-timezone UTC
# Create custom MOTD
cat > /etc/update-motd.d/10-custom-motd <<'EOF'
#!/bin/bash
# Set hostname
hostnamectl set-hostname ${HOSTNAME}
# Create user
useradd -m -s /bin/bash ${USERNAME}
# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --authkey=${TAILSCALE_AUTH_KEY} --hostname=${HOSTNAME}

# Dynamic MOTD
HOSTNAME=$(hostname)
KERNEL=$(uname -r)
UPTIME=$(uptime -p)
LOAD=$(cat /proc/loadavg | awk '{print $1 ", " $2 ", " $3}')
MEMORY=$(free -h | grep "Mem:" | awk '{print $3 "/" $2}')
DISK=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
USERS=$(who | wc -l)
INTERNAL_IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v "127.0.0.1" | head -n 1)
TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "Not connected")
cat > /etc/motd << EOF
Welcome to $HOSTNAME
Managed by Muso Systems.

System Information:
Kernel: $KERNEL
Uptime: $UPTIME
Load: $LOAD
Memory: $MEMORY
Disk Usage: $DISK
Internal IP: $INTERNAL_IP
Tailscale IP: $TAILSCALE_IP
Users: $USERS active
EOF
# Set MOTD permissions and clean up default MOTD files
chmod +x /etc/update-motd.d/10-custom-motd
rm -f /etc/update-motd.d/00-header
rm -f /etc/update-motd.d/10-help-text
rm -f /etc/update-motd.d/50-landscape-sysinfo
rm -f /etc/update-motd.d/50-motd-news
rm -f /etc/update-motd.d/60-unminimize
rm -f /etc/update-motd.d/85-fwupd
rm -f /etc/update-motd.d/88-esm-announce
rm -f /etc/update-motd.d/91-contract-ua-esm-status
rm -f /etc/update-motd.d/91-release-upgrade
rm -f /etc/update-motd.d/95-hwe-eol
rm -f /etc/motd
touch /etc/motd

# Install and configure Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
sysctl -p /etc/sysctl.d/99-tailscale.conf
tailscale up --auth-key=$TAILSCALE_AUTH_KEY --hostname=$HOSTNAME
tailscale set --ssh

# Configure VM specific settings
systemctl enable qemu-guest-agent
systemctl start qemu-guest-agent
modprobe acpiphp
modprobe pci_hotplug
udevadm control --reload-rules
udevadm trigger
systemctl daemon-reload
systemctl disable rpcbind
systemctl stop rpcbind
echo "memhp_default_state=online" >> /etc/default/grub.d/99-cloudimg-settings.cfg
update-grub

# Restart MOTD service
systemctl restart systemd-update-motd
