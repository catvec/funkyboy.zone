#!/usr/bin/env bash
#?
# upload.sh - Upload repository to server
#
# USAGE
#
#	upload.sh ADDRESS [--no-chown]
#
# ARGUMENTS
#
#	ADDRESS    Server address, can include username if required
#
# OPTIONS
#
#	--no-chown    Don't chown files with a group
#
# BEHAVIOR
#
#	Uploads repository to /opt/funkyboy.zone on the server
#
#?

# Exit on any error
set -e

# Arguments
while [ ! -z "$1" ]; do
	case "$1" in
		--no-chown)
			no_chown="true"
			shift
			;;

		*)
			address="$1"
			shift
			;;
	esac
done

# Check for address argument
if [ -z "$address" ]; then
	echo "Error: ADDRESS argument required" >&2
	exit 1
fi

# Upload
echo "===== Uploading"

prog_path=$(dirname "$0")
repo_path=$(realpath "$prog_path/..")

if ! rsync \
	--exclude .git \
	-r "$repo_path" "$address":/opt/; then
	echo "Error: Failed to upload repository files to $address" >&2
	exit 1
fi

# Chown
if [ -z "$no_chown" ]; then
	echo "===== Chowning"

	if ! ssh "$address" "sudo chown -R :salt /opt/funkyboy.zone"; then
		echo "Error: Failed to chown repository files on host" >&2
		exit 1
	fi
fi

echo "Done"
