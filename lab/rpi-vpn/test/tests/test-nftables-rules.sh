#!/bin/bash

# Test nftables configuration

set -eu

# Pillar values
readonly SSH_PORT="{{ pillar.ssh.port }}"
readonly WG_PORT="{{ pillar.wireguard.listen_port }}"
readonly PUBLIC_INTERFACE="{{ pillar.wireguard.public_interface }}"

SALT_SSH_SCRIPT="/repo/lab/rpi-vpn/scripts/salt-ssh"
ROSTER_FILE="/repo/lab/rpi-vpn/test/roster.yaml"

# Change to repo root so salt-ssh script works properly
cd /repo/lab/rpi-vpn

echo "Testing nftables firewall rules on rpi-vpn..."

# Test SSH port accessibility (should work)
echo "Testing SSH port $SSH_PORT accessibility..."
if nc -z 10.10.10.208 "$SSH_PORT"; then
    echo "✓ SSH port $SSH_PORT is accessible through firewall"
else
    echo "✗ SSH port $SSH_PORT is blocked by firewall"
    exit 1
fi

# Test WireGuard port accessibility (should work)
echo "Testing WireGuard port $WG_PORT accessibility..."
if nc -u -z 10.10.10.208 "$WG_PORT"; then
    echo "✓ WireGuard port $WG_PORT is accessible through firewall"
else
    echo "✗ WireGuard port $WG_PORT is blocked by firewall"
    exit 1
fi

# Test that a random high port is blocked (should fail)
echo "Testing that random ports are blocked..."
if ! nc -z 10.10.10.208 9999; then
    echo "✓ Random port 9999 is correctly blocked by firewall"
else
    echo "✗ Random port 9999 should be blocked but is accessible"
    exit 1
fi

echo "✓ All nftables rules validated successfully"
exit 0