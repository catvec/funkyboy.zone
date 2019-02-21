#!/usr/bin/env bash
#?
# build.sh - Build Node Exporter
#
# USAGE
#
#	build.sh
#
# BEHAVIOR
#
#	Creates a temporary GOPATH workspace and builds Node Exporter inside.
#
#?

# {{{1 Exit on any error
set -e

# {{{1 Configuration
prog_dir=$(realpath $(dirname "$0"))
gh_repo="github.com/prometheus/node_exporter"

# {{{1 Setup build GOPATH
export GOPATH="$prog_dir/build-gopath"

if ! mkdir -p "$GOPATH"; then
	echo "Error: Failed to create build GOPATH directory" >&2
	exit 1
fi

# {{{1 Get program
if ! go get "$gh_repo"; then
	echo "Error: Failed to fetch node exporter" >&2
	exit 1
fi

# {{{1 Build
# {{{2 Switch to directory
if ! cd "$GOPATH/src/$gh_repo"; then
	echo "Error: Failed to change to node exporter directory" >&2
	exit 1
fi

# {{{2 Build
if ! make; then
	echo "Error: Failed to build" >&2
	exit 1
fi

echo "OK"
