#!/usr/bin/env bash
#?
# init.sh - Initial server setup
#
# USAGE
#
#	init.sh
#
# BEHAVIOR
#
#	Performs initial setup tasks on the server:
#
#	Sets the root password to something new (prompts user).
#
#	Deletes misc files in /root which are left over from the custom 
#	DigitalOcean image setup process.
#
#	Installs Salt.
#
#	Symlinks repository {salt,pillar} directories from to 
#	/srv/{salt,pillar} on the server.
#
#?

# Exit on any error
set -e

# Delete misc files in /root
echo "===== Deleting misc files in /root"

if [ -f /root/*.tar.gz ]; then
	if ! rm /root/*.tar.gz; then
		echo "Error: Failed to delete .tar.gz files" >&2
		exit 1
	fi
fi

if [ -d /root/* ]; then
	if ! rm -rf /root/*; then
		echo "Error: Failed to delete directories" >&2
		exit 1
	fi
fi
