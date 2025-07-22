#!/usr/bin/env bash
set -eux
set -o pipefail

while getopts "h" opt; do
    case "$opt" in
        h)
            cat <<EOF
build-and-push.sh - Build and push Docker image

Usage: build-and-push.sh [-h]

Image tag is hard coded. Edit script to change.
EOF
            exit 0;
            ;;
            '?') exit 1 ;;
    esac
done

readonly PROG_DIR=$(realpath $(dirname "$0"))
readonly DOCKER=docker
readonly IMAGE_TAG="2025-07-21-0"
readonly IMAGE_NAME="isolation0230/funkyboy-zone"
readonly IMAGE_FULLNAME="${IMAGE_NAME}:${IMAGE_TAG}"

"$DOCKER" build -t "$IMAGE_FULLNAME" "$PROG_DIR"
"$DOCKER" push "$IMAGE_FULLNAME"
