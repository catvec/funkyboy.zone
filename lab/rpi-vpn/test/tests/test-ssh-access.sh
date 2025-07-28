#!/bin/bash

# Test SSH access to configured containers

set -eu

# Pillar values
readonly SSH_PORT="{{ pillar.ssh.port }}"

# Test SSH to router container
echo "Testing SSH access to router on port $SSH_PORT..."
if nc -z 10.10.10.208 "$SSH_PORT"; then
    echo "✓ SSH port $SSH_PORT is open on router"
    exit 0
else
    echo "✗ SSH port $SSH_PORT is not accessible on router"
    exit 1
fi