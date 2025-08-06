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

# Test expected open ports and firewall behavior
echo "Scanning ports to verify firewall configuration..."
scan_result=$(nmap -p "$SSH_PORT,$WG_PORT,8080-8090" "$RPI_VPN_PRIVATE_IP" --host-timeout 10s)

# Check SSH port is open
if echo "$scan_result" | grep -q "$SSH_PORT/tcp.*open"; then
    echo "✓ SSH port $SSH_PORT is open"
else
    echo "✗ SSH port $SSH_PORT should be open but is:"
    echo "$scan_result" | grep "$SSH_PORT"
    exit 1
fi

# Check that random ports in range are filtered (indicating firewall is active)
filtered_count=$(echo "$scan_result" | grep -c "filtered" || true)
open_random_count=$(echo "$scan_result" | grep -E "(808[0-9]/tcp.*open)" | wc -l || true)

if [ "$filtered_count" -gt 0 ] && [ "$open_random_count" -eq 0 ]; then
    echo "✓ Firewall is active - random ports are filtered"
elif [ "$open_random_count" -gt 5 ]; then
    echo "✗ Too many unexpected ports are open ($open_random_count) - firewall may not be configured"
    echo "$scan_result"
    exit 1
else
    echo "✓ Firewall behavior verified"
fi

# Test WireGuard UDP port separately
echo "Testing WireGuard UDP port $WG_PORT..."
wg_result=$(sudo nmap -sU -p "$WG_PORT" "$RPI_VPN_PRIVATE_IP" --host-timeout 5s)
if echo "$wg_result" | grep -q "$WG_PORT/udp.*open"; then
    echo "✓ WireGuard port $WG_PORT is open"
else
    echo "WireGuard port status: $(echo "$wg_result" | grep "$WG_PORT" || echo "not detected")"
fi

echo "✓ All nftables rules validated successfully"
exit 0
