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

# Set root password
echo "===== Setting root password"
echo "(You will be prompted for a new password)"

if ! passwd root; then
	echo "Error: Failed to set root password" >&2
	exit 1
fi

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

# Install Salt
echo "===== Installing Salt"

if ! which salt &> /dev/null; then
	if ! xbps-install -Sy salt; then
		echo "Error: Failed to install salt" >&2
		exit 1
	fi
else
	echo "Already installed"
fi

# Symlink salt files
echo "===== Symlinking salt files"

if [ ! -d /srv ]; then
	if ! mkdir /srv; then
		echo "Error: Failed to make /srv directory" >&2
		exit 1
	fi
else
	echo "/srv directory already exists"
fi

for symlink_dir in salt pillar secrets/salt secrets/pillar; do
	if [ ! -d "/srv/$symlink_dir" ]; then
		if ! ln -s "/opt/funkyboy.zone/$symlink_dir" "/srv/$symlink_dir"; then
			echo "Error: Failed to symlink /srv/$symlink_dir directory" >&2
			exit 1
		fi
	else
		echo "/srv/$symlink_dir directory already symlinked"
	fi
done
