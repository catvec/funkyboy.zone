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

symlink_sources=(salt pillar secret/salt secret/pillar)
symlink_targets=(/srv/salt /srv/pillar /srv/salt-secret /srv/pillar-secret)

for i in $(seq 0 $((${#symlink_sources[@]} - 1))); do
	symlink_source=${symlink_sources[$i]}
	symlink_target=${symlink_targets[$i]}

	# Check if target dir exists
	if [ ! -d "$symlink_target" ]; then
		# Symlink
		if ! ln -s "/opt/funkyboy.zone/$symlink_source" "$symlink_target"; then
			echo "Error: Failed to symlink $symlink_source to $symlink_target directory" >&2
			exit 1
		fi

		echo "Symlinked $symlink_source to $symlink_target"
	else
		echo "$symlink_target directory already symlinked"
	fi
done
