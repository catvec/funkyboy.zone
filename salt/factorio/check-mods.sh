#!/usr/bin/env bash
#?
# check-mods-fs.sh - Determines if mods file system has been mounted
#
# USAGE
#
#	check-mods-fs.sh OPTIONS
#
# OPTIONS
#
#	-d DIR      Mods directory
#	-s SPACE    Digital Ocean mods Space
#
# BEHAVIOR
#
#	Checks if the mods directory has been mounted via s3fs-fuse.
#
# 	Exits with non-zero status if mods directory is not mounted.
#
#?

# {{{1 Exit on any error
set -e

# {{{1 Options
# {{{2 Get
while getopts "d:s:" opt; do
	case "$opt" in
		d)
			mods_dir="$OPTARG"
			;;

		s)
			mods_space="$OPTARG"
			;;

		'?')
			echo "Error: Unknown option \"$opt\"" >&2
			exit 1
			;;
	esac
done

# {{{2 Check
# {{{3 mods_dir
if [ -z "$mods_dir" ]; then
	echo "Error: -d DIR option required" >&2
	exit 1
fi

# {{{3 mods_space
if [ -z "$mods_space" ]; then
	echo "Error: -s SPACE option required" >&2
	exit 1
fi

# {{{1 If mods dir doesn't exist
if [ ! -d "$mods_dir" ]; then
	echo "Mods directory doesn't exist: $mods_dir"
	exit 1
fi

# {{{1 Check if any mods do not exist on disk
mod_file_names=()

while read mod_info; do
	# {{{2 Parse mod file info
	# Command outputs
	#
	#	DATE TIME SIZE MD5 S3PATH
	#
	remote_file_md5=$(echo "$mod_info" | awk '{ print $4 }')
	s3_path=$(echo "$mod_info" | awk '{ print $5 }')
	mod_file=$(echo "$s3_path" | sed "s/s3:\/\/$mods_space\/\(.*\)/\1/g")

	# {{{2 Record mod file name for future use
	mod_file_names+=("$mod_file")

	# {{{2 Check if mod exists
	if [ ! -f "$mods_dir/$mod_file" ]; then # If doesn't exist
		echo "Mod $mod_file doesn't exist"
		exit 1
	else # File does exist
		# {{{3 Check file's md5
		existing_md5=$(md5sum "$mods_dir/$mod_file" | awk '{ print $1 }')

		if [[ "$remote_file_md5" != "$existing_md5" ]]; then
			# If md5's don't match then get new version
			echo "Mods $mod_file md5 sums do not match"
			exit 1
		fi
	fi
done <<< $(run-s3cmd --list-md5 ls "s3://$mods_space")

# {{{1 Check if any mods are on the disk which shouldn't be
# For each file in mods dir
while read local_file; do
	local_file=$(basename "$local_file")

	# {{{ 2 For each file in Digital Ocean mods space
	for remote_file in "${mod_file_names[@]}"; do
		# {{{3 Compare
		if [[ "$local_file" == "$remote_file" ]]; then
			matches="true"
		fi
	done

	# {{{ 2 If mod which shouldn't exist on disk does
	if [ -z "$matches" ]; then
		# Mod should be removed
		echo "Mod $local_file should not exist on disk"
		exit 1
	fi
done <<< $(ls "$mods_dir"/*)

echo "DONE"
