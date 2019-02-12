#!/usr/bin/env bash
#?
# upload.sh - Upload repository to server
#
# USAGE
#
#	upload.sh [-u USER] [-h HOST] [-n]
#
# OPTIONS
#
#	-u USER    User with which to access server
#	-h HOST    Host with which to access server
#	-n         Do not chown uploaded folders to Salt group
#
# BEHAVIOR
#
#	Uploads repository to /opt/funkyboy.zone on the server
#
#?

# Exit on any error
set -e

# Arguments
while getopts "u:h:n" opt; do
	case "$opt" in
		u)
			user="$OPTARG"
			;;

		h)
			host="$OPTARG"
			;;

		n)
			no_chown="true"
			;;

		'?')
			show-help "$0"
			exit 1
			;;
	esac
done

if [ -z "$user" ]; then
	user="$USER"
fi

if [ -z "$host" ]; then
	host="funkyboy.zone"
fi

address="$user@$host"

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
