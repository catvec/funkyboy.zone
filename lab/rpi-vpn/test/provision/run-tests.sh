#!/bin/bash
set -eu

echo "Running Salt SSH tests..."

# Set PATH for Salt binaries
export PATH="/opt/salt/:/opt/salt/bin/:$PATH"

# Wait for other VMs to be ready
echo "Waiting for RPI-VPN VM to be ready..."
RETRY_COUNT=0
MAX_RETRIES=30

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if nc -z 10.10.10.208 22; then
        echo "RPI-VPN VM is ready!"
        break
    fi
    echo "Waiting for SSH on RPI-VPN VM... (attempt $((RETRY_COUNT + 1))/$MAX_RETRIES)"
    sleep 2
    RETRY_COUNT=$((RETRY_COUNT + 1))
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "ERROR: RPI-VPN VM failed to become ready"
    exit 1
fi

# Change to the repo directory 
cd /repo/lab/rpi-vpn

# Run the test framework
/repo/lab/rpi-vpn/test/scripts/run-tests.sh