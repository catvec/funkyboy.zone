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
    nftables \
    wireguard \
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
cat /repo/secret/lab/rpi-vpn/pki/management_key.pub >> /home/vagrant/.ssh/authorized_keys

# Enable and start SSH service
systemctl enable ssh
systemctl start ssh

# Enable IP forwarding for WireGuard
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding=1' >> /etc/sysctl.conf
sysctl -p

echo "RPI-VPN VM provisioned successfully!"
