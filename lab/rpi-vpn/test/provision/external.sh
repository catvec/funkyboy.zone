#!/bin/bash
set -eu

echo "Provisioning External server VM..."

# Update system
apt-get update
apt-get upgrade -y

# Install basic tools for testing
apt-get install -y \
    python3 \
    bash \
    iproute2 \
    iputils-ping \
    netcat-openbsd

# Start simple HTTP server on port 80 for NAT testing
cat > /etc/systemd/system/test-http-server.service << 'EOF'
[Unit]
Description=Test HTTP Server
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 -m http.server 80
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl enable test-http-server
systemctl start test-http-server

echo "External server VM provisioned successfully!"