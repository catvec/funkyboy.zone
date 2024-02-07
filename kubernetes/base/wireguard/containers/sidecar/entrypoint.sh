#!/usr/bin/env bash
# Constants
WIREGUARD_PEER_CONF="/config/wg_confs/peer.conf"

# Helpers
die() { # (msg, code)
    msg="$1"
    code=$2

    echo "Error: $msg" >& 2
    exit $code
}

# Check required env vars
if [[ -z "$WIREGUARD_PEER" ]]; then
    die "WIREGUARD_PEER env var must be set"
fi

if [[ -z "$WIREGUARD_NAMESPACE" ]]; then
    export WIREGUARD_NAMESPACE=wireguard
fi

cat <<EOF
Setting up Wireguard peer
==========================
Name         $WIREGUARD_PEER
Namespace    $WIREGUARD_NAMESPACE
Peer File    $WIREGUARD_PEER_CONF
EOF

mkdir -p $(dirname "$WIREGUARD_PEER_CONF")
kubectl -n "$WIREGUARD_NAMESPACE" get wireguardpeer "$WIREGUARD_PEER" --template={{.status.config}} | bash | tee "$WIREGUARD_PEER_CONF" &> /dev/null

exec /init