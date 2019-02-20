#!/usr/bin/env bash
#?
# backup.sh - Backup Funky Boy system files to a Digital Ocean Space
# 
# USAGE
#
#	backup.sh OPTIONS
#
# OPTIONS
#
#	-s SPACE    Name of Digital Ocean Space to upload backups
#	-3 CFG_F    Location of s3cmd configuration file
#
# BEHAVIOR
#
#	Backs up system files to a Digital Ocean space. 
#
#	First creates a GZip compressed tar ball of the file to backup. This 
#	tar ball is named via the format:
#
#		backup-%Y-%m-%d-%H:%M:%S.tar.gz
#	
#	(Using strftime formatting rules)
#
#	Then uploads these files to the Digital Ocean Space specified by SPACE.
#
# 	After the successful upload the tar ball is deleted.
#
#?

# {{{1 Exit on any error
set -e

# {{{1 Configuration
out_dir="/var/tmp"
backup_f_date_fmt="+%Y-%m-%d-%H:%M:%S"
backup_f_targets=("/public" "/home")
space="funkyboy-zone-backup"

# {{{1 Software requirements
# {{{2 Date exists
if ! which date &> /dev/null; then
	echo "Error: Date utility must be installed" >&2
	exit 1
fi

# {{{2 Date is GNU
if ! date --version | grep "GNU" &> /dev/null; then
	echo "Error: Date utility must be GNU" >&2
	exit 1
fi

# {{{1 Arguments
# {{{2 Get
while getopts "s:3:" opt; do
	case "$opt" in
		s)
			space="$OPTARG"
			;;

		3)
			s3cmd_cfg_f="$OPTARG"
			;;

		'?')
			echo "Unknown argument \"$opt\"" >&2
			exit 1
			;;
	esac
done

# {{{2 Check for missing
# {{{3 space
if [ -z "$space" ]; then
	echo "Error: -s SPACE option required" >&2
	exit 1
fi

# {{{3 s3cmd_cfg_f
if [ -z "$s3cmd_cfg_f" ]; then
	echo "Error: -3 CFG_F option required" >&2
	exit 1
fi

# {{{2 Validate
if [ ! -f "$s3cmd_cfg_f" ]; then
	echo "Error: s3cmd configuration file \"$s3cmd_cfg_f\" does not exist" >&2
	exit 1
fi

# {{{1 Create backup file format
backup_f_date=$(date "$backup_f_date_fmt")

if [[ "$?" != "0" ]]; then
	echo "Error: Failed to get date portion of backup file name" >&2
	exit 1
fi

backup_f_path="$out_dir/backup-$backup_f_date.tar"

echo "Backup file name will be $backup_f_path"

# {{{1 Define cleanup function
function cleanup() {
	rm "$backup_f_path"* || true
}

# {{{1 Create backup file
# -h    Dereference symlinks
# -u    Update archive
# -v    Verbose
# -f    Output archive name
for target in "${backup_f_targets[@]}"; do
	echo "Backing up $target"

	if ! tar -huvf "$backup_f_path" "$target"; then
		echo "Error: Failed to create backup tar ball for $target" >&2
		cleanup
		exit 1
	fi
done

# {{{1 Compress backup file
compressed_backup_f_path="$backup_f_path.gz"

echo "Compressing backup file as $compressed_backup_f_path"

if ! gzip "$backup_f_path"; then
	echo "Error: Failed to compress backup file" >&2
	cleanup
	exit 1
fi

# {{{1 Upload to space
echo "Uploading to Digital Ocean Space $space"

if ! s3cmd put "$compressed_backup_f_path" "s3://$space/" -c "$s3cmd_cfg_f"; then
	echo "Error: Failed to upload backup to space" >&2
	cleanup
	exit 1
fi

cleanup

echo "DONE"
