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
while getopts "d:s:r:" opt; do
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

# {{{1 Create mods directory if doesn't exist
if ! mkdir -p "$mods_dir"; then
	echo "Error: Failed to create mods directory: $mods_dir" >&2
	exit 1
fi

# {{{1 Copy mods
if ! run-s3cmd get \
	--skip-existing \
	--recursive \
	"s3://$mods_space" "$mods_dir/"; then

	echo "Error: Failed to copy mods" >&2
	exit 1
fi

# {{{1 Remove any mods which shouldn't exist
# {{{2 Get names of files in mods space
mods_space_files=()

while read mod_info; do
	# {{{2 Parse mod file info
	# Command outputs
	#
	#	DATE TIME SIZE MD5 S3PATH
	#
	s3_path=$(echo "$mod_info" | awk '{ print $5 }')
	mod_file=$(echo "$s3_path" | sed "s/s3:\/\/$mods_space\/\(.*\)/\1/g")

	# {{{2 Record mod file name for future use
	mods_space_files+=("$mod_file")
done <<< $(run-s3cmd --list-md5 ls "s3://$mods_space")

# {{{2 Check for files which shouldn't exist
while read local_file; do
	local_file=$(basename "$local_file")

	# {{{ 2 For each file in Digital Ocean mods space
	for remote_file in "${mods_space_files[@]}"; do
		# {{{3 Compare
		if [[ "$local_file" == "$remote_file" ]]; then
			matches="true"
		fi
	done

	# {{{ 2 If mod which shouldn't exist on disk does
	if [ -z "$matches" ]; then
		# Mod should be removed
		if ! rm "$mods_dir/$local_file"; then
			echo "Error: Failed to delete old mod $local_file" >&2
			exit 1
		fi
	fi
done <<< $(ls "$mods_dir"/*)

# {{{1 Restart factorio service
if ! sv restart "$factorio_svc"; then
	echo "Error: Failed to restart Factorio service" >&2
	exit 1
fi
