#!/usr/bin/env bash
#?
# zip.sh - Zips mod directories
#
# USAGE
#
#	zip.sh
#
# BEHAVIOR
#
# 	Create a zip file of all mods.
#
#?

# {{{1 Exit on any error
set -e

# {{{1 Get program directory
prog_dir=$(realpath $(dirname "$0"))

# {{{1 Configuration
# Directory in which mod zip files are stored
mod_zips_dirname="mod_zips"
mod_zips_dir="$prog_dir/$mod_zips_dirname"

# Directory in which the zip file containing all mod zip files will be stored
all_mods_zip_dirname="all_mods_zip"
all_mods_zip_dir="$prog_dir/$all_mods_zip_dirname"

# {{{1 Make output directory
if ! mkdir -p "$all_mods_zip_dir"; then
	echo "Error: Failed to make output directory: $all_mods_zip_dir" >&2
	exit 1
fi

# {{{1 Create all mods zip
cd "$mod_zips_dir"

all_mods_zip_f="../$all_mods_zip_dirname/all_mods.zip"

if [ -f "$all_mods_zip_f" ]; then
	if ! rm "$all_mods_zip_f"; then
		echo "Error: Failed to clean $all_mods_zip_f" >&2
		exit 1
	fi
fi

if ! zip "$all_mods_zip_f" $(ls -d *); then
	echo "Error: Failed to create all mods zip" >&2
	exit 1
fi

echo "Done"
