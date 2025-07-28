#!/bin/bash
set -eu

echo "Provisioning Salt SSH Orchestrator VM..."

# Update system
apt-get update
apt-get upgrade -y

# Install dependencies for Salt onedir and testing tools
apt-get install -y \
    bash \
    curl \
    python3 \
    python3-pip \
    nmap \
    netcat-openbsd \
    jq \
    xz-utils \
    ssh \
    iproute2 \
    iputils-ping \
    gettext-base

# Install Salt 3007.6 manually via onedir tar
echo "Installing Salt 3007.6..."
curl -fsSL "https://packages.broadcom.com/artifactory/saltproject-generic/onedir/3007.6/salt-3007.6-onedir-linux-x86_64.tar.xz" -o salt.tar.xz
tar -xf salt.tar.xz -C /opt/
rm salt.tar.xz

# Update PATH to include Salt binaries
echo 'export PATH="/opt/salt/:/opt/salt/bin/:$PATH"' >> /etc/profile
echo 'export PATH="/opt/salt/:/opt/salt/bin/:$PATH"' >> /root/.bashrc

# Configure SSH to skip host key verification for testing
mkdir -p /home/vagrant/.ssh
cat > /home/vagrant/.ssh/config << 'EOF'
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF

echo "Orchestrator VM provisioned successfully!"
