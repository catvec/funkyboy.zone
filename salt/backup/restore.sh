#!/usr/bin/env bash
#?
# restore.sh - Restore backup files onto machine
#
# USAGE
#
#	restore.sh OPTIONS
#
# OPTIONS
#
#	-s SPACE        Name of Digital Ocean Space to upload backups
#	-c CFG_F        Location of s3cmd configuration file
#
# BEHAVIOR
#
#	Downloads latest backup and restores the file to the machine.
#
#?

# {{{1 Exit on any error
set -e

# {{{1 Load shared functions file
prog_dir=$(realpath $(dirname "$0"))

. "$prog_dir/lib-backup.sh"

# {{{1 Configuration
wrking_dir="/var/tmp"
extract_dir="$wrking_dir/out"

# {{{1 Arguments
# {{{2 Get
while getopts "s:c:" opt; do
	case "$opt" in
		s)
			space="$OPTARG"
			;;

		c)
			s3cmd_cfg_f="$OPTARG"
			;;

		'?')
			echo "Error: Unknown option $opt" >&2
			exit 1
			;;
	esac
done

# {{{2 Validate
# {{{3 space
if [ -z "$space" ]; then
	echo "Error: -s SPACE option is required" >&2
	exit 1
fi

# {{{3 s3cmd_cfg_f
if [ -z "$s3cmd_cfg_f" ]; then
	echo "Error: -c CFG_F option is required" >&2
	exit 1
fi

# {{{1 Get latest backup
latest_backup_epoch=""
latest_backup_s3_path=""
while read file_info; do
	# {{{2 Get epoch backup was created
	# file_info format
	#
	#	date time size f_s3_path
	#
	f_s3_path=$(echo "$file_info" | awk '{ print $4 }')

	f_date=$(echo "$f_s3_path" | sed 's/.*backup-\(.*\)\.tar\.gz/\1/g')
	f_date_epoch=$(file_date_to_epoch "$f_date")

	# {{{2 Determine if latest epoch
	if [ -z "$latest_backup_epoch" ] || (( "$f_date_epoch" > "$latest_backup_epoch" )); then
		latest_backup_epoch="$f_date_epoch"
		latest_backup_s3_path="$f_s3_path"
	fi
done <<< $(s3cmd -c "$s3cmd_cfg_f" ls "s3://$space/")

if [ -z "$latest_backup_epoch" ]; then
	echo "Error: Failed to find latest backup" >&2
	exit 1
fi

# {{{1 Download
echo "===== Downloading backup $latest_backup_s3_path"

# {{{2 Download
# {{{3 Cleanup function
function cleanup() {
	rm "$wrking_dir"/backup-* || true
	rm -rf "$extract_dir" || true
}

if ! s3cmd -c "$s3cmd_cfg_f" get "$latest_backup_s3_path" "$wrking_dir"; then
	echo "Error: Failed to download latest backup" >&2
	cleanup
	exit 1
fi

# {{{2 Record file name
backup_f_path=$(echo "$latest_backup_s3_path" | sed 's/.*\(backup-.*\)/\1/g')
backup_f_path="$wrking_dir/$backup_f_path"

# {{{1 Extract
echo "===== Extracting backup"

# {{{2 Make extract directory
if ! mkdir -p "$extract_dir"; then
	echo "Error: Failed to make extract directory: $extract_dir" >&2
	cleanup
	exit 1
fi

if ! tar -xzf "$backup_f_path" -C "$extract_dir"; then
	echo "Error: Failed to extract backup" >&2
	cleanup
	exit 1
fi

# {{{1 Restore files
echo "===== Restoring files"

while read f; do
	restore_path=$(echo "$f" | sed 's/^out\(\/.*\)/\1/g')

	echo "----- Restoring $f to $restore_path"

	if cp "$f" "$restore_path"; then
		echo "Error: Failed to restore" >&2
		cleanup
		exit 1
	fi
done <<< $(find "$extract_dir" -name '*' -type f)

cleanup

echo "DONE"
