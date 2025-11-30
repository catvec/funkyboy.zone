#!/usr/bin/env bash
# https://github.com/MisterCalvin/supermicro-java-ikvm
set -eou pipefail

declare -r PROG_DIR=$(dirname $(realpath "$0"))
declare -r MOUNT_DIR="${PROG_DIR}/ipmi-kvm-mnt"
declare -r ENV_FILE="$PROG_DIR/../.env"

if [[ -f "$ENV_FILE" ]]; then
    source "$ENV_FILE"
fi

exec docker run -d \
  --name=supermicro-java-ikvm \
  -e TZ="UTC" \
  -e USER_ID="1000" \
  -e GROUP_ID="1000" \
  -e KVM_HOST="$KVM_HOST" \
  -e KVM_USER="$KVM_USER" \
  -e KVM_PASS="$KVM_PASS" \
  -e DISPLAY_WIDTH="1024" \
  -e DISPLAY_HEIGHT="768" \
  -p 5800:5800 \
  -p 5900:5900 \
  -v "$MOUNT_DIR/vmedia:/app/vmedia/" \
  -v "$MOUNT_DIR/screenshots:/app/screenshots/" \
  -v supermicro-java-ikvm:/config/ \
  --restart no \
  ghcr.io/mistercalvin/supermicro-java-ikvm:latest
