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
#	-s SPACE        Name of Digital Ocean Space to upload backups
#	-c CFG_F        Location of s3cmd configuration file
#	-r FLAG_F       Flag file to touch when backup successfully runs
#	-b FILE         File / directory to backup, can be specified 
#	                multiple times
#	-e EXCLUDE_F    Files to exclude from backup
#	-f              Force backup occur even if program determines it is
#	                too soon for another backup
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

# {{{1 Load shared functions file
prog_dir=$(realpath $(dirname "$0"))

. "$prog_dir/lib-backup.sh"

# {{{1 Configuration
out_dir="/var/tmp"

backup_f_date_fmt="+%Y-%m-%d-%H:%M:%S"
#backup_f_targets=("/public" "/home")

always_delete_backup=31557600 # 1 year
always_delete_backup_txt="1 year"

oldest_backup=2592000 # 1 month
oldest_backup_txt="1 month"

earliest_backup=43200 # 12 hours
earliest_backup_txt="12 hours"

backup_f_targets=()
backup_f_exclude=()

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
while getopts "s:c:r:b:e:f" opt; do
	case "$opt" in
		s)
			space="$OPTARG"
			;;

		c)
			s3cmd_cfg_f="$OPTARG"
			;;

		r)
			status_flag_file="$OPTARG"
			;;

		b)
			backup_f_targets+=("$OPTARG")
			;;

		e)
			backup_f_exclude+=("$OPTARG")
			;;

		f)
			force_backup="true"
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
	echo "Error: -c CFG_F option required" >&2
	exit 1
fi

# {{{3 status_flag_file
if [ -z "$status_flag_file" ]; then
	echo "Error: -r FLAG_F option required" >&2
	exit 1
fi

# {{{3 backup_f_targets
if [[ "${#backup_f_targets[@]}" == "0" ]]; then
	echo "Error: -b FILE option must be specified at least once" >&2
	exit 1
fi

# {{{2 Validate
# {{{3 s3cmd_cfg_f
if [ ! -f "$s3cmd_cfg_f" ]; then
	echo "Error: s3cmd configuration file \"$s3cmd_cfg_f\" does not exist" >&2
	exit 1
fi

# {{{3 backup_f_targets
for f in "${backup_f_targets[@]}"; do
	if [ ! -f "$f" ] && [ ! -e "$f" ] && [ ! -d "$f" ]; then
		echo "Error: Backup target file \"$f\" does not exist" >&2
		exit 1
	fi
done

# {{{1 Create backup file format
backup_f_date=$(date "$backup_f_date_fmt")

if [[ "$?" != "0" ]]; then
	echo "Error: Failed to get date portion of backup file name" >&2
	exit 1
fi

backup_f_path="$out_dir/backup-$backup_f_date.tar"

echo "===== Backup file name will be $backup_f_path"

# {{{1 Check if backup made recently
echo "===== Performing maintenance on existing backups"
while read file_info; do
	if [ -z "$file_info" ]; then
		continue
	fi
	# {{{2 Get epoch backup was created
	# file_info format
	#
	#	date time size f_s3_path
	#
	f_s3_path=$(echo "$file_info" | awk '{ print $4 }')

	f_date=$(echo "$f_s3_path" | sed 's/.*backup-\(.*\)\.tar\.gz/\1/g')
	f_date_day=$(echo "$f_date" | awk -F '-' '{ print $3 }')
	f_date_epoch=$(file_date_to_epoch "$f_date")

	# {{{2 Figure out how long ago backup was made
	now=$(date +%s)
	dt=$(("$now - $f_date_epoch"))

	# {{{2 Determine if backup was created too recently
	if (( "$dt" < "$earliest_backup" )); then
		# Check if force argument is provided
		if [ ! -z "$force_backup" ]; then
			echo "Backup created within the last $earliest_backup_txt but -f argument provided"
		else
			echo "Error: Backup created within the last $earliest_backup_txt, wait until 12 hours from $f_date" >&2
			exit 1
		fi
	fi

	# {{{2 Determine if a backup should be deleted
	if (( "$dt" > "$always_delete_backup" )); then
		echo "Deleting backup older than $always_delete_backup_txt, all backups of this age are always deleted, date: $f_date"
		if ! s3cmd -c "$s3cmd_cfg_f" rm "$f_s3_path"; then
			echo "Error: Failed to delete old backup $f_s3_path" >&2
			exit 1
		fi
	elif (( "$dt" > "$oldest_backup" )); then
		# Keep every backup on the 30th day of a month unless older than a year
		if [[ "$(($f_date_day % 30))" == "0" ]]; then
			echo "Keeping old backup on 30th day of month, date: $f_date"
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

	# {{{2 Build exclude arguments
	tar_exclude_args=""

	for f in "${backup_f_exclude[@]}"; do
		tar_exclude_args="$tar_exclude_args --exclude=$f"
	done

	echo "tar exclude args: $tar_exclude_args"

	# {{{2 Archive
	if ! tar -huvf "$backup_f_path" $tar_exclude_args "$target"; then
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

# {{{1 Indicate successfully ran
if ! touch "$status_flag_file"; then
	echo "Error: Failed to touch status flag file \"$status_flag_file\" to indicate ran successfully" >&2
	exit 1
fi

echo "DONE"
