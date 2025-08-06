#!/bin/bash

# Test SSH access to configured containers

set -eu

# Source VM configuration
source /repo/lab/rpi-vpn/test/vm-config.env

# Pillar values
readonly SSH_PORT="{{ pillar.ssh.port }}"
readonly SSH_USER="{{ pillar['users'][pillar['ssh']['allow_ssh_from']]['username'] }}"

# Test SSH to router container with actual authentication
echo "Testing SSH access to router on port $SSH_PORT..."
if ssh -o IdentitiesOnly=yes -i /repo/secret/lab/rpi-vpn/pki/management_key -p "$SSH_PORT" "${SSH_USER}@${RPI_VPN_PRIVATE_IP}" 'echo "SSH connection successful"'; then
    echo "✓ SSH authentication successful on port $SSH_PORT"
    exit 0
else
    echo "✗ SSH authentication failed on port $SSH_PORT"
    exit 1
fi
