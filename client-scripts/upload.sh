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
#	-u USER    (Optional) User with which to access server, defaults to
#	           current user
#	-h HOST    (Optional) Host with which to access server, defaults 
#	           to funkyboy.zone
#	-n         Do not chown uploaded folders to Salt group
#
# BEHAVIOR
#
#	Uploads repository to /opt/funkyboy.zone on the server
#
#?

# Helpers
function bold() {
    echo "$(tput bold)$@$(tput sgr0)"
}

function die() {
    echo "Error: $@" >&2
    exit 1
}

function check() {
    if [ "$?" -ne 0 ]; then
	   die "$@"
    fi
}

# Arguments
while getopts "u:h:n" opt; do
	case "$opt" in
		u) user="$OPTARG" ;;
		h) host="$OPTARG" ;;
		n) no_chown="true" ;;
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
bold "Uploading"

prog_path=$(dirname "$0")
repo_path=$(realpath "$prog_path/..")

rsync \
    --exclude .git \
    -r "$repo_path" "$address":/opt/
check "Failed to upload repository files to $address"

# Chown
if [ -z "$no_chown" ]; then
	bold "Chowing"

	ssh "$address" "sudo chown -R :salt /opt/funkyboy.zone"
	check "Failed to chown repository files on host"
fi

bold "Done"
