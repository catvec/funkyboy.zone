#!/usr/bin/env bash
#?
# mount-mods-fs.sh - Mount factorio mods file system
#
# USAGE
#
#	mount-mods-fs.sh OPTIONS
#
# OPTIONS
#
#	-d MODS_DIR    Mods directory
#	-s SPACE       Digital Ocean Space which contains mods
#	-r SVC         Factorio runit service name
#	-u USER_ID     User ID to own mods directory
#	-g GROUP_ID    Group ID to own mods directory
#
# BEHAVIOR
#
#	Mounts a Digital Ocean Space which contains Factorio mods onto the 
# 	local file system.
#
#?

# {{{1 Exit on any error
set -e

# {{{1 Options
# {{{2 Get
while getopts "d:s:r:u:g:" opt; do
	case "$opt" in
		d)
			mods_dir="$OPTARG"
			;;

		s)
			mods_space="$OPTARG"
			;;
		
		r)
			factorio_svc="$OPTARG"
			;;

		u)
			user_id="$OPTARG"
			;;

		g)
			group_id="$OPTARG"
			;;

		'?')
			echo "Error: Unknown option \"$opt\"" >&2
			exit 1
			;;
	esac
done

# {{{2 Verify
# {{{3 mods_dir
if [ -z "$mods_dir" ]; then
	echo "Error: -d MODS_DIR option required" >&2
	exit 1
fi

# {{{3 mods_space
if [ -z "$mods_space" ]; then
	echo "Error: -s SPACE option required" >&2
	exit 1
fi

# {{{3 factorio_svc
if [ -z "$factorio_svc" ]; then
	echo "Error: -r SVC option required" >&2
	exit 1
fi

# {{{3 user
if [ -z "$user_id" ]; then
	echo "Error: -u USER_ID option required" >&2
	exit 1
fi

# {{{3 group
if [ -z "$group_id" ]; then
	echo "Error: -g GROUP_ID option required" >&2
	exit 1
fi

# {{{1 Create mods directory if doesn't exist
if ! mkdir -p "$mods_dir"; then
	echo "Error: Failed to create mods directory: $mods_dir" >&2
	exit 1
fi

# {{{1 Remove old mods list if exists
mod_list_f="$mods_dir/mod-list.json"
if [ -f "$mod_list_f" ]; then
	if ! rm "$mod_list_f"; then
		echo "Error: Failed to delete old mods list file: $mod_list_f" >&2
		exit 1
	fi
fi

# {{{1 Mount space as mods fs
if ! run-s3fs \
	-o "uid=$user_id,umask=000,gid=$group_id" \
	"$mods_space" "$mods_dir"; then
	echo "Error: Failed to mount mods filesystem" >&2
	exit 1
fi

# {{{1 Restart factorio service
if ! sv restart "$factorio_svc"; then
	echo "Error: Failed to restart Factorio service" >&2
	exit 1
fi
