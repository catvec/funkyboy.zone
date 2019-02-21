#!/usr/bin/env bash

# Converts a backup file's time date component into epoch
#
# ARGUMENTS
#
#	1. date    Date portion string to convert
#
# OUTPUTS
#
#	Epoch conversion
#
function file_date_to_epoch() { # ( date )
	# {{{2 Arguments
	if [ -z "$1" ]; then
		echo "Error: file_date_to_epoch(): date argument required" >&2
		exit 1
	fi
	date="$1"

	# {{{2 Convert to GNU date default format
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
