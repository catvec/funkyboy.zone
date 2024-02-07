#!/usr/bin/env bash
die() { # (msg, code)
    msg="$1"
    code=$2

    echo "Error: $msg" >& 2
    exit $code
}

if [[ -z "$WIREGUARD_PEER" ]]; then
    die "WIREGUARD_PEER env var must be set"
fi

if [[ -z "$WIREGUARD_NAMESPACE" ]]; then
    export WIREGUARD_NAMESPACE=wireguard
fi

kubectl -n "$WIREGUARD_NAMESPACE" get wireguardpeer "$WIREGUARD_PEER" --template={{.status.config}} | bash | tee /config/wg_confs/peer.conf