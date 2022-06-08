#!/usr/bin/env bash
declare -r PROG_DIR=$(realpath $(dirname "$0"))

declare -r MANIFEST_URL="https://operatorhub.io/install/argocd-operator.yaml"
declare -r MANIFEST_OUT="$PROG_DIR/../base/argocd-operator-subscription.yaml"

curl -L "$MANIFEST_URL" -o "$MANIFEST_OUT"
