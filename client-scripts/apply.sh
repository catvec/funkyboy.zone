#!/usr/bin/env bash
#?
# apply.sh - Apply Salt states to server
#
# USAGE
#
#	apply.sh ADDRESS [--test,-t]
#
# ARGUMENTS
#
#	ADDRESS    Server address
#
# OPTIONS
#
#	--test,-t    Run Salt in test mode
#
# BEHAVIOR
#
#	Applies Salt states to the server
#
#?

# Exit on any error
set -e

# Get script directory
prog_dir=$(realpath $(dirname "$0"))

# Arguments
while [ ! -z "$1" ]; do
	case "$1" in
		--test|-t)
			salt_test="true"
			shift
			;;

		*)
			address="$1"
			shift
			;;
	esac
done

# Upload files
echo "===== Uploading files"

if ! "$prog_dir"/upload.sh "$address"; then
	echo "Error: Failed to upload files" >&2
	exit 1
fi

# Apply salt
echo "===== Applying Salt states"

if [ ! -z "$salt_test" ]; then
	salt_post_args="$salt_post_args test=true"
fi

if ! ssh "$address" "salt-call --local --force-color state.apply $salt_post_args"; then
	echo "Error: Failed to apply Salt states" >&2
	exit 1
fi

echo "Done"
