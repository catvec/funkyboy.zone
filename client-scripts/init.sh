#!/usr/bin/env bash
#?
# init.sh - Perform initial setup on server
#
# USAGE
#
#	init.sh ADDRESS
#
# ARGUMENTS
#
#	ADDRESS    Server address
#
# BEHAVIOR
#
#	Performs initial server setup. Uploads repository and runs 
#	the server-scripts/init.sh script.
#
#?

# Exit on any error
set -e

# Get script directory
prog_dir=$(realpath $(dirname "$0"))

# Address argument
if [ -z "$1" ]; then
	echo "Error: ADDRESS argument is required" >&2
	exit 1
fi
address="$1"

# Copy SSH id
echo "===== Copying SSH id"

if ! ssh-copy-id "$address"; then
	echo "Error: Failed to copy SSH id" >&2
	exit 1
fi

# Install rsync
echo "===== Installing rsync on server if needed"

if ! ssh "$address" 'which rsync || xbps-install -Sy rsync'; then
	echo "Error: Failed to install rsync on server" >&2
	exit 1
fi

# Upload
echo "===== Uploading files"

if ! "$prog_dir"/upload.sh "$address"; then
	echo "Error: Failed to upload files" >&2
	exit 1
fi

# Run init script
echo "===== Running init script on server"

if ! ssh "$address" /opt/funkyboy.zone/server-scripts/init.sh; then
	echo "Error: Failed to run init script on server" >&2
	exit 1
fi

echo "Done"
