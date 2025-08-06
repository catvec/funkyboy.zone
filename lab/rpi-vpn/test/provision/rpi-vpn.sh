#!/bin/bash
set -eu

echo "Provisioning RPI-VPN target VM..."

# Update system
apt-get update
apt-get upgrade -y

# Install SSH server and dependencies for Salt SSH
apt-get install -y \
    openssh-server \
    python3 \
    python3-pip \
    sudo \
    bash \
    iproute2 \
    iputils-ping \
    systemd

# Create SSH host keys and SSH directory
mkdir -p /var/run/sshd
ssh-keygen -A

# Create salt user with sudo access (for Salt SSH)
useradd -m -s /bin/bash salt || true
echo "salt:salt" | chpasswd
echo "salt ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure SSH for Salt SSH access
sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config
# Create admin user with sudo privileges
useradd -m -s /bin/bash admin || true
echo "admin:admin" | chpasswd
echo "admin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up SSH for admin user
mkdir -p /home/admin/.ssh
chmod 700 /home/admin/.ssh
chown admin:admin /home/admin/.ssh

# Add management key to admin's authorized_keys
cat /repo/secret/lab/rpi-vpn/pki/management_key.pub >> /home/admin/.ssh/authorized_keys
chmod 600 /home/admin/.ssh/authorized_keys
chown admin:admin /home/admin/.ssh/authorized_keys

echo "Created admin user and added management key"

# Enable and start SSH service
systemctl enable ssh
systemctl start ssh

echo "RPI-VPN VM provisioned successfully!"
