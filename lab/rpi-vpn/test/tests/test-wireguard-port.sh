#!/bin/bash

# Test WireGuard port accessibility

set -eu

# Pillar values
readonly WG_PORT="{{ pillar.wireguard.listen_port }}"

echo "Testing WireGuard port $WG_PORT on router..."
if nc -u -z 10.10.10.208 "$WG_PORT"; then
    echo "✓ WireGuard port $WG_PORT is open on router"
    exit 0
else
    echo "✗ WireGuard port $WG_PORT is not accessible on router"
    exit 1
fi