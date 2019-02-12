#!/usr/bin/env bash
#?
# init.sh - Perform initial setup on server
#
# USAGE
#
#	init.sh [-u USER] [-h HOST]
#
# OPTIONS
#
#	-u USER    (Optional) User with which to access server, defaults
#	           to "root"
#	-h HOST    (Optional) Host with which to access server, defaults
#	           to funkyboy.zone
#
# BEHAVIOR
#
#	Performs initial server setup. Uploads repository and runs 
#	the server-scripts/init.sh script.
#
#?

# {{1 Exit on any error
set -e

# {{{1 Get script directory
prog_dir=$(realpath $(dirname "$0"))

# Arguments
while getopts "u:a:nt" opt; do
	case "$opt" in
		u)
			user="$OPTARG"
			;;

		h)
			host="$OPTARG"
			;;

		'?')
			show-help "$0"
			exit 1
			;;
	esac
done

if [ -z "$user" ]; then
	user="root"
fi

if [ -z "$host" ]; then
	host="funkyboy.zone"
fi

address="$user@$host"

# Copy SSH id
echo "===== Copying SSH id"

if ! ssh-copy-id "$address"; then
	echo "Error: Failed to copy SSH id" >&2
	exit 1
fi

# Install rsync
echo "===== Installing rsync on server if needed"

if ! ssh "$address" 'which rsync &> /dev/null || xbps-install -Sy rsync'; then
	echo "Error: Failed to install rsync on server" >&2
	exit 1
fi

# Upload
echo "===== Uploading files"

if ! "$prog_dir"/upload.sh -u "$user" -h "$host" -n; then
	echo "Error: Failed to upload files" >&2
	exit 1
fi

# Run init script
echo "===== Running init script on server"

if ! ssh "$address" /opt/funkyboy.zone/server-scripts/init.sh; then
	echo "Error: Failed to run init script on server" >&2
	exit 1
fi

# Apply salt state
echo "===== Applying salt state for first time"

if ! "$prog_dir/apply.sh" -u "$user" -h "$host" -n; then
	echo "Error: Failed to apply salt state for first time" >&2
	exit 1
fi

echo "Done"
