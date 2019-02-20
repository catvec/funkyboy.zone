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
# DEPENDENCIES
#
#	tar, gzip, GNU date, and GNU sed
#
#?

# {{{1 Exit on any error
set -e

# {{{1 Configuration
out_dir="/var/tmp"

backup_f_date_fmt="+%Y-%m-%d-%H:%M:%S"
backup_f_targets=("/public" "/home")

oldest_backup=2592000 # 1 month
oldest_backup_txt="1 month"

earliest_backup=43200 # 12 hours
earliest_backup_txt="12 hours"

# {{{1 Software requirements
# {{{2 GNU Date 
# {{{3 Exists
if ! which date &> /dev/null; then
	echo "Error: Date utility must be installed" >&2
	exit 1
fi

# {{{3 Is GNU
if ! date --version | grep "GNU" &> /dev/null; then
	echo "Error: Date utility must be GNU" >&2
	exit 1
fi

# {{{2 tar
if ! which tar &> /dev/null; then
	echo "Error: Tar utility must be installed" >&2
	exit 1
fi

# {{{2 gzip
if ! which gzip &> /dev/null; then
	echo "Error: GZip must be installed" >&2
	exit 1
fi

# {{{2 GNU sed
# {{{3 Exists
if ! which sed &> /dev/null; then
	echo "Error: Sed utility must be installed" >&2
	exit 1
fi

# {{{3 Is GNU
if ! sed --version | grep "GNU" &> /dev/null; then
	echo "Error: Sed utility must be GNU" >&2
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

echo "===== Backup file name will be $backup_f_path"

# {{{1 Check if backup made recently
# {{{2 Date conversion helper
function file_date_to_epoch() { # ( date )
	# {{{2 Arguments
	if [ -z "$1" ]; then
		echo "Error: file_date_to_epoch(): date argument required" >&2
		exit 1
	fi
	date="$1"

	# {{{2 Convert to GNU date default format
	# 2019-02-20-15:42:13
	year=$(echo "$date" | awk -F '-' '{ print $1 }')
	month=$(echo "$date" | awk -F '-' '{ print $2 }')
	day=$(echo "$date" | awk -F '-' '{ print $3 }')
	time_part=$(echo "$date" | sed 's/.*-.*-\(.*\)/\1/g')

	gnu_formatted_date="$month/$day/$year $time_part"

	# {{{2 Get as epoch
	epoch=$(date -d "$gnu_formatted_date" +%s)
	if [[ "$?" != "0" ]]; then
		echo "Error: file_date_to_epoch($date): Failed to convert to epoch" >&2
		exit 1
	fi

	echo "$epoch"
}

# {{{2 Get existing backups
echo "===== Performing maintenance on existing backups"
while read file_info; do
	# {{{3 Get epoch backup was created
	# file_info format
	#
	#	date time size f_s3_path
	#
	f_s3_path=$(echo "$file_info" | awk '{ print $4 }')

	f_date=$(echo "$f_s3_path" | sed 's/.*backup-\(.*\)\.tar\.gz/\1/g')
	f_date_day=$(echo "$f_date" | awk -F '-' '{ print $3 }')
	f_date_epoch=$(file_date_to_epoch "$f_date")

	# {{{3 Figure out how long ago backup was made
	now=$(date +%s)
	dt=$(("$now - $f_date_epoch"))

	# {{{3 Determine if backup was created too recently
	if (( "$dt" < "$earliest_backup" )); then
		echo "Error: Backup created within the last $earliest_backup_txt, wait until 12 hours from $f_date" >&2
		exit 1
	fi

	# {{{3 Determine if a backup should be deleted
	if (( "$dt" < "$oldest_backup" )); then
		# Keep every backup on the 30th day of a month no matter the age
		if [[ "$(($f_date_day % 30))" == "0" ]]; then
			echo "Keeping old backup on 30th day of month $f_date"
			continue
		else
			echo "Deleting backup older than $oldest_backup_txt, date: $f_date"
			if ! s3cmd -c "$s3cmd_cfg_f" rm "$f_s3_path"; then
				echo "Error: Failed to delete old backup $f_s3_path" >&2
				exit 1
			fi
		fi
	fi
done <<< $(s3cmd -c "$s3cmd_cfg_f" ls "s3://$space/")

# {{{1 Define cleanup function
function cleanup() {
	rm "$backup_f_path"* || true
}

# {{{1 Create backup file
echo "===== Creating archive"

# -h    Dereference symlinks
# -u    Update archive
# -v    Verbose
# -f    Output archive name
for target in "${backup_f_targets[@]}"; do
	echo "----- Backing up $target"

	if ! tar -huvf "$backup_f_path" "$target"; then
		echo "Error: Failed to create backup tar ball for $target" >&2
		cleanup
		exit 1
	fi
done

# {{{1 Compress backup file
compressed_backup_f_path="$backup_f_path.gz"

echo "===== Compressing backup file as $compressed_backup_f_path"

if ! gzip "$backup_f_path"; then
	echo "Error: Failed to compress backup file" >&2
	cleanup
	exit 1
fi

# {{{1 Upload to space
echo "===== Uploading to Digital Ocean Space $space"

if ! s3cmd -c "$s3cmd_cfg_f" put "$compressed_backup_f_path" "s3://$space/"; then
	echo "Error: Failed to upload backup to space" >&2
	cleanup
	exit 1
fi

cleanup

echo "DONE"
