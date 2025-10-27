#!/bin/bash

# Test WireGuard VPN connectivity to external network

set -eu

# Source VM configuration
source /repo/lab/rpi-vpn/test/vm-config.env

# Pillar values for WireGuard configuration
readonly WG_PORT="{{ pillar.wireguard.listen_port }}"
readonly CLIENT_PRIVATE_KEY="{{ pillar.wireguard.wg_profiles.wg0.peers[0].private_key }}"
readonly CLIENT_ADDRESS="{{ pillar.wireguard.wg_profiles.wg0.peers[0].address }}"
readonly SERVER_PUBLIC_KEY="{{ pillar.wireguard.wg_profiles.wg0.public_key }}"
readonly SERVER_ADDRESS="{{ pillar.wireguard.wg_profiles.wg0.address }}"

echo "Testing WireGuard VPN connectivity..."

# Test 1: Verify external server is NOT accessible without VPN (isolation test)
echo "Testing network isolation (external server should be unreachable)..."
if timeout 5 ping -c 1 "$EXTERNAL_SERVER_IP" > /dev/null 2>&1; then
    echo "✗ External server $EXTERNAL_SERVER_IP is directly accessible - network not isolated!"
    exit 1
else
    echo "✓ External server $EXTERNAL_SERVER_IP is not directly accessible (network isolated)"
fi

# Test 2: Create WireGuard client configuration
echo "Creating WireGuard client configuration..."
WG_CONFIG="/tmp/wg-test-client.conf"

cat > "$WG_CONFIG" << EOF
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = $CLIENT_ADDRESS

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = ${RPI_VPN_PUBLIC_IP}:$WG_PORT
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

echo "Generated WireGuard config for client $CLIENT_ADDRESS -> server ${RPI_VPN_PUBLIC_IP}:$WG_PORT"

# Test 3: Bring up VPN tunnel
echo "Establishing WireGuard VPN tunnel..."
if sudo wg-quick up "$WG_CONFIG"; then
    echo "✓ WireGuard tunnel established"
else
    echo "✗ Failed to establish WireGuard tunnel"
    sudo rm -f "$WG_CONFIG"
    exit 1
fi

# Test 4: Verify tunnel is active
echo "Verifying WireGuard tunnel status..."
if sudo wg show | grep -q "peer.*$(echo $SERVER_PUBLIC_KEY | cut -c1-8)"; then
    echo "✓ WireGuard tunnel is active with server peer"
else
    echo "✗ WireGuard tunnel not properly established"
    sudo wg-quick down "$WG_CONFIG" || true
    sudo rm -f "$WG_CONFIG"
    exit 1
fi

# Test 5: Test connectivity through VPN
echo "Testing connectivity through VPN tunnel..."
if timeout 10 ping -c 3 "$EXTERNAL_SERVER_IP" > /dev/null 2>&1; then
    echo "✓ External server $EXTERNAL_SERVER_IP is accessible through VPN"
else
    echo "✗ External server $EXTERNAL_SERVER_IP is not accessible through VPN"
    sudo wg-quick down "$WG_CONFIG" || true
    sudo rm -f "$WG_CONFIG"
    exit 1
fi

# Test 6: Verify traffic is routed through WireGuard interface
echo "Verifying traffic routing through VPN..."
WG_INTERFACE=$(basename "$WG_CONFIG" .conf)
if ip route get "$EXTERNAL_SERVER_IP" | grep -q "dev $WG_INTERFACE"; then
    echo "✓ Traffic to external server routes through WireGuard interface"
else
    echo "⚠ Warning: Could not verify routing through WireGuard interface"
fi

# Cleanup
echo "Cleaning up WireGuard tunnel..."
sudo wg-quick down "$WG_CONFIG"
sudo rm -f "$WG_CONFIG"

echo "✓ WireGuard VPN connectivity test completed successfully"
exit 0
