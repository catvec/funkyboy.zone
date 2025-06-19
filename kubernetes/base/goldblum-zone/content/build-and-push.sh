#!/usr/bin/env bash
set -eux
set -o pipefail

readonly PROG_DIR=$(realpath $(dirname "$0"))
readonly DOCKER=docker
readonly IMAGE_TAG="2025-06-19-0"
readonly IMAGE_NAME="isolation0230/goldblum-zone"
readonly IMAGE_FULLNAME="${IMAGE_NAME}:${IMAGE_TAG}"

"$DOCKER" build -t "$IMAGE_FULLNAME" "$PROG_DIR"
"$DOCKER" push "$IMAGE_FULLNAME"
