#!/usr/bin/env bash
#?
# upload.sh - Upload repository to server
#
# USAGE
#
#	upload.sh ADDRESS
#
# ARGUMENTS
#
#	ADDRESS    Server address, can include username if required
#
# BEHAVIOR
#
#	Uploads repository to /opt/funkyboy.zone on the server
#
#?

# Exit on any error
set -e

# Check for address argument
if [ -z "$1" ]; then
	echo "Error: ADDRESS argument required" >&2
	exit 1
fi
address="$1"

# Upload
prog_path=$(dirname "$0")
repo_path=$(realpath "$prog_path/..")

if ! rsync -r "$repo_path"  "$address":/opt/; then
	echo "Error: Failed to upload repository files to $address" >&2
	exit 1
fi

echo "Done"
