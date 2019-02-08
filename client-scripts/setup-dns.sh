#!/usr/bin/env bash
#?
# setup-dns.sh - Create DNS records
#
# USAGE
# 
#	setup-dns.sh [MODE] [OPTIONS]
#
# ARGUMENTS
#
#	MODE    (Optional) Operation to perform, defaults to "set", valid 
#	        values are:
#
#	            - set: Set DNS entries
#	            - delete: Delete DNS entries
#
# OPTIONS
#
#	--dry-run    Don't actually execute any commands, print what will 
#	             be done
#
# BEHAVIOR
#
#	MODE == create
#
#		Create DNS records pointing towards a droplet with the 
#		name: funkyboy.zone
#
#	MODE == delete
#
#		Delete DNS A records with host value: `*` or `@`
#
# DEPENDENCIES
#
#	doctl command required.
#?

# {{{1 Exit on any error
set -e

# {{{1 Configuration
target_droplet_name="funkyboy.zone"
entry_ttl="60"
domain_names=("funkyboy.zone" "noahh.io" "noahhuppert.com")

mode_set="set"
mode_delete="delete"

# {{{1 Parse arguments
while [ ! -z "$1" ]; do
	case "$1" in
		--dry-run)
			dry_run="true"
			echo "DRY RUN"
			shift
			;;

		*)
			mode="$1"
			shift
			;;
	esac
done

if [ -z "$mode" ]; then
	mode="$mode_set"
fi

# {{{1 Check for doctl
if ! which doctl &> /dev/null; then
	echo "Error: doctl not installed" >&2
	exit 1
fi

if [[ "$mode" == "$mode_set" ]]; then
	echo "############"
	echo "# Mode Set #"
	echo "############"

	# {{{1 Get IPv4 of droplet
	while read droplet_info; do
		name=$(echo "$droplet_info" | awk '{ print $1 }')
		ipv4=$(echo "$droplet_info" | awk '{ print $2 }')

		if [[ "$name" == "$target_droplet_name" ]]; then
			target_droplet_ipv4="$ipv4"
			break
		fi
	done <<< $(doctl compute droplet list --format "Name,PublicIPv4" --no-header)

	if [ -z "$target_droplet_ipv4" ]; then
		echo "Error: Failed to find droplet with name \"$target_droplet_name\"" >&2
		exit 1
	fi

	# {{{1 Create or update DNS entries
	for domain in "${domain_names[@]}"; do
		echo
		echo "===== $domain"

		# {{{2 For each record name
		for host in '*' '@'; do
			echo " --------"
			echo "| Type $host |"
			echo " --------"

			# {{{3 Check if entry exists
			while read entry_info; do
				id=$(echo "$entry_info" | awk '{ print $1 }')
				t=$(echo "$entry_info" | awk '{ print $2 }')
				name=$(echo "$entry_info" | awk '{ print $3 }')
				data=$(echo "$entry_info" | awk '{ print $4 }')
				ttl=$(echo "$entry_info" | awk '{ print $5 }')

				# {{{3 Check if entry exists
				if [[ "$t" == "A" && "$name" == "$host" ]]; then # Exists
					echo "Record found $id"

					# {{{4 Check if entry has correct data
					if [[ "$data" == "$target_droplet_ipv4" && "$ttl" == "$entry_ttl" ]]; then # Correct data
						entry_ok="$id"
						break
					else # Incorrect data
						update_entry_id="$id"
						break
					fi
				fi

			done <<< $(doctl compute domain records list "$domain" --format "ID,Type,Name,Data,TTL" --no-header)

			# {{{3 Update or create
			if [ ! -z "$entry_ok" ]; then
				echo "Data and TTL correct"
			elif [ -z "$update_entry_id" ]; then # Create
				echo "No record found, creating"

				if [ -z "$dry_run" ]; then
					if ! doctl compute domain records create "$domain" \
						--record-type "A" \
						--record-name "$host" \
						--record-ttl "$entry_ttl" \
						--record-data "$target_droplet_ipv4"; then
						echo "Error: Failed to create record" >&2
						exit 1
					fi
					echo
				else
					echo "[dry run] create record, type: A, name: $host, data: $target_droplet_ipv4"
				fi
			else # Update
				echo "Data and / or TTL incorrect, updating"

				if [ -z "$dry_run" ]; then
					if ! doctl compute domain records update "$domain" \
						--record-id "$id" \
						--record-ttl "$entry_ttl" \
						--record-data "$target_droplet_ipv4"; then
						echo "Error: Failed to set data for record" >&2
						exit 1
					fi
					echo
				else
					echo "[dry run] update record, ID: $id, data: $target_droplet_ipv4"
				fi
			fi
		done
	done
elif [[ "$mode" == "$mode_delete" ]]; then
	echo "###############"
	echo "# Mode Delete #"
	echo "###############"

	# {{{1 For each domain
	for domain in "${domain_names[@]}"; do
		echo "===== $domain"

		# {{{2 For each domain entry
		while read entry_info; do
			# {{{3 Check if domain entry should be deleted
			id=$(echo "$entry_info" | awk '{ print $1 }')
			t=$(echo "$entry_info" | awk '{ print $2 }')
			name=$(echo "$entry_info" | awk '{ print $3 }')
			data=$(echo "$entry_info" | awk '{ print $4 }')

			if [[ "$t" == "A" && ("$name" == '*' || "$name" == "@") ]]; then
				echo "Deleting $id"

				if [ -z "$dry_run" ]; then
					if ! doctl compute domain records delete -f "$domain" "$id"; then
						echo "Error: Failed to delete record" >&2
						exit 1
					fi
					echo
				else
					echo "[dry run] delete record, id: $id, type: $t, name: $name, data: $data"
				fi
			fi

		done <<< $(doctl compute domain records list "$domain" --format "ID,Type,Name,Data" --no-header)
	done
else
	echo "Error: Invalid MODE argument value: \"$mode\"" >&2
	exit 1
fi
