#!/bin/bash

# Test WireGuard port accessibility

set -eu

# Source VM configuration
source /repo/lab/rpi-vpn/test/vm-config.env

# Pillar values
readonly WG_PORT="{{ pillar.wireguard.listen_port }}"

echo "Testing WireGuard port $WG_PORT on router..."
if nc -u -z "$RPI_VPN_PRIVATE_IP" "$WG_PORT"; then
    echo "✓ WireGuard port $WG_PORT is open on router"
    exit 0
else
    echo "✗ WireGuard port $WG_PORT is not accessible on router"
    exit 1
fi
