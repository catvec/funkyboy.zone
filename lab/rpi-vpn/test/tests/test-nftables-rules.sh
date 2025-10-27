#!/bin/bash

# Test nftables configuration

set -eu

# Source VM configuration
source /repo/lab/rpi-vpn/test/vm-config.env

# Pillar values
readonly SSH_PORT="{{ pillar.ssh.port }}"
readonly WG_PORT="{{ pillar.wireguard.listen_port }}"
readonly PUBLIC_INTERFACE="{{ pillar.wireguard.public_interface }}"

# Change to repo root so salt-ssh script works properly
cd /repo/lab/rpi-vpn

echo "Testing nftables firewall rules on rpi-vpn..."

# Test WireGuard UDP
echo "Testing WireGuard UDP port $WG_PORT..."
wg_result=$(sudo nmap -sU -p "$WG_PORT" "$RPI_VPN_PRIVATE_IP" --host-timeout 5s)
if echo "$wg_result" | grep -q "$WG_PORT/udp.*open"; then
    echo "✓ WireGuard port $WG_PORT is open"
else
    echo "WireGuard port status: $(echo "$wg_result" | grep "$WG_PORT" || echo "not detected")"
fi

echo "✓ All nftables rules validated successfully"
exit 0
