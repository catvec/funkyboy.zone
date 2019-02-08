#!/usr/bin/env bash
#?
# setup-droplet.sh - Setup Digital Ocean droplet
#
# USAGE
#
#	setup-droplet.sh [MODE] [OPTIONS]
#
# ARGUMENTS
#
#	MODE    (Optional) Action script will perform, defaults to "create". 
#	        Valid values are:
#
#	            - create: Create droplet
#	            - delete: Delete droplet
#
# OPTIONS
#
#	--dry-run    Do not run any commands, instead print out what 
#	             would happen
#
# BEHAVIOR
#
#	MODE == create
#
#		Create droplet with name funkyboy.zone
#
#	MODE == delete
#
#		Delete droplet with name funkyboy.zone
#
# NOTES
#
#	target_droplet_name and target_image_name, and target_ssh_key_name 
#	configuration variable CANNOT have a space in it. This will cause awk 
#	to split fields incorrectly when using the doctl command line interface
#
# DEPENDENCIES
#
#	doctl command line interface required
#?

# {{{1 Exit on any error
set -e

# {{{1 Configuration
mode_create="create"
mode_delete="delete"

target_droplet_name="funkyboy.zone"
target_droplet_region="nyc1"
target_droplet_size="s-1vcpu-2gb"

target_image_name="Void-Linux"

target_ssh_key_name="Katla"

# {{{2 Check certain configuration fields don't have spaces in them
if [[ "$target_ssh_key_name" =~ ^(.* .*)$ ]]; then
	echo "Error: target_ssh_key_name cannot have a space in it, this will cause awk to split fields incorrectly when interpreting doctl output" >&2
	exit 1
fi

if [[ "$target_droplet_name" =~ ^(.* .*)$ ]]; then
	echo "Error: target_droplet_name cannot have a space in it, this will cause awk to split fields incorrectly when interpreting doctl output" >&2
	exit 1
fi

if [[ "$target_image_name" =~ ^(.* .*)$ ]]; then
	echo "Error: target_image_name cannot have a space in it, this will cause awk to split fields incorrectly when interpreting doctl output" >&2
	exit 1
fi

# {{{1 Arguments
while [ ! -z "$1" ]; do
	case "$1" in
		--dry-run)
			dry_run="true"
			shift
			;;

		*)
			mode="$1"
			shift
			;;
	esac
done

if [ -z "$mode" ]; then
	mode="$mode_create"
fi

if [ ! -z "$dry_run" ]; then
	echo "DRY RUN"
fi

# {{{1 Check for doctl
if ! which doctl &> /dev/null; then
	echo "Error: doctl must be installed" >&2
	exit 1
fi

# {{{1 Check if droplet exists
while read droplet_info; do
	id=$(echo "$droplet_info" | awk '{ print $1 }')
	name=$(echo "$droplet_info" | awk '{ print $2 }')

	if [[ "$name" == "$target_droplet_name" ]]; then
		target_droplet_id="$id"
		break
	fi
done <<< $(doctl compute droplet list --format "ID,Name" --no-header)

# {{{1 Depending on mode stop execution if droplet does or does not exist
if [[ "$mode" == "$mode_create" ]]; then
	# {{{2 If droplet already exists exit
	if [ ! -z "$target_droplet_id" ]; then
		echo "Error: Droplet already exists, cannot create, id: $target_droplet_id" >&2
		exit 1
	fi
elif [[ "$mode" == "$mode_delete" ]]; then
	# {{{2 If droplet doesn't exist exit
	if [ -z "$target_droplet_id" ]; then
		echo "Error: Droplet does not exist, cannot delete, id: $target_droplet_id" >&2
		exit 1
	fi
fi

# {{{1 Run
if [[ "$mode" == "$mode_create" ]]; then
	echo "###############"
	echo "# Mode Create #"
	echo "###############"

	# {{{2 Find ID of image
	while read image_info; do
		id=$(echo "$image_info" | awk '{ print $1 }')
		name=$(echo "$image_info" | awk '{ print $2 }')
		t=$(echo "$image_info" | awk '{ print $3 }')

		if [[ "$name" == "$target_image_name" && "$t" == "custom" ]]; then
			target_image_id="$id"
			break
		fi
	done <<< $(doctl compute image list --format "ID,Name,Type" --no-header)

	if [ -z "$target_image_id" ]; then
		echo "Error: Failed to find image with name \"$target_image_name\"" >&2
		exit 1
	fi

	# {{{2 Find ID of ssh key id
	while read ssh_key_info; do
		id=$(echo "$ssh_key_info" | awk '{ print $1 }')
		name=$(echo "$ssh_key_info" | awk '{ print $2 }')

		if [[ "$name" == "$target_ssh_key_name" ]]; then
			target_ssh_key_id="$id"
			break
		fi
	done <<< $(doctl compute ssh-key list --format "ID,Name" --no-header)

	if [ -z "$target_ssh_key_id" ]; then
		echo "Error: Failed to find ID of SSH key with name \"$target_ssh_key_name\"" >&2
		exit 1
	fi

	# {{{2 Create droplet
	if [ -z "$dry_run" ]; then
		echo "Creating"

		if ! doctl compute droplet create "$target_droplet_name" \
			--image "$target_image_id" \
			--region "$target_droplet_region" \
			--size "$target_droplet_size" \
			--ssh-keys "$target_ssh_key_id" \
			--enable-backups \
			--wait; then
			echo "Error: Failed to create droplet" >&2
			exit 1
		fi
	else
		echo "[dry run] create droplet, image id: $target_image_id, region: $target_droplet_region, size: $target_droplet_size, ssh key id: $target_ssh_key_id, enable backups"
	fi
elif [[ "$mode" == "$mode_delete" ]]; then
	echo "###############"
	echo "# Mode Delete #"
	echo "###############"

	# {{{2 Confirm delete
	echo "Are you sure you want to delete the funkyboy.zone droplet, id: $target_droplet_id? [y/N]"
	read confirm_delete
	if [[ "$confirm_delete" != "y" ]]; then
		echo "Error: Failed to confirm delete" >&2
		exit 1
	fi

	if [ -z "$dry_run" ]; then
		if ! doctl compute droplet delete "$target_droplet_id"; then
			echo "Error: Failed to delete droplet" >&2
			exit 1
		fi
	else
		echo "[dry run] Delete droplet, id: $target_droplet_id"
	fi
else
	echo "Error: Invalid MODE \"$mode\"" >&2
	exit 1
fi
