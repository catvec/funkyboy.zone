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

# {{{1 If mods dir doesn't exist
if [ ! -d "$mods_dir" ]; then
	echo "Mods directory doesn't exist: $mods_dir"
	exit 1
fi

# {{{1 Check if mounted
if ! mount | grep "^s3fs on $mods_dir type fuse.s3fs"; then
	echo "Not mounted"
	exit 1
fi

echo "DONE"
