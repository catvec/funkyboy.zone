#!/usr/bin/env bash
#?
# get-ip.sh - Get IP of Digital Ocean droplet
#
# USAGE
#
# 	get-ip.sh
# 
# BEHAVIOR
#
# 	Prints IP of Digital Ocean droplet using API
#
# DEPENDENCIES
#
#	doctl command line interface is required
#
#?

# {{{1 Exit on any error
set -e

# {{{1 Configuration
target_droplet_name="funkyboy.zone"

# {{{1 Get IP
while read droplet_info; do
	name=$(echo "$droplet_info" | awk '{ print $1 }')
	ipv4=$(echo "$droplet_info" | awk '{ print $2 }')

	if [[ "$name" == "$target_droplet_name" ]]; then
		target_droplet_ipv4="$ipv4"
		break
	fi
done <<< $(doctl compute droplet list --format "Name,PublicIPv4" --no-header)

if [ -z "$target_droplet_ipv4" ]; then
	echo "Error: Failed to find ipv4 of droplet with name \"$target_droplet_name\"" >&2
	exit 1
fi

echo "$target_droplet_ipv4"
