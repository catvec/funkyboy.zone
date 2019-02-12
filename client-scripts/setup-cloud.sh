#!/usr/bin/env bash
#?
# setup-cloud.sh - Sets up cloud resources on Digital Ocean
#
# USAGE
#
#	setup-cloud.sh [-t] [-d] [-i] [-h]
#
# OPTIONS
#
#	-t    Show plan for creation of resources instead of creating resources
#	-d    Destroy resources
#	-h    Show help text
#
# BEHAVIOR
#
#	Sets up a droplet and domain entries.
#
# DEPENDENCIES
#
#	Terraform must be installed.
#
#	The DO_API_TOKEN environment variable must be set.
#
#?

# {{{1 Exit on any error
set -e

# {{{1 Get script directory
prog_dir=$(realpath $(dirname "$0"))

# {{{1 Configuration
tf_state_file=$(realpath "$prog_dir/../secret/terraform.tfstate")

# {{{1 Arguments
while getopts "tdih" opt; do
	case "$opt" in
		t)
			arg_test="true"
			;;

		d)
			arg_destroy="true"
			;;

		h)
			show-help "$0"
			exit 1
			;;

		'?')
			show-help "$0"
			exit 1
			;;
	esac
done

# {{{1 Dependencies
# {{{2 Check for terraform
if ! which terraform &> /dev/null; then
	echo "Error: Terraform must be installed: terraform.io" >&2
	exit 1
fi

# {{{2 Check fo DO_API_TOKEN
if [ -z "$DO_API_TOKEN" ]; then
	echo "Error: DO_API_TOKEN environment variable must be set" >&2
	exit 1
fi

# {{{1 Switch to terraform working directory
cd "$prog_dir"

# {{{1 Initialize terraform
if ! terraform init; then
	echo "Error: Failed to initialize terraform" >&2
	exit 1
fi

# {{{1 Run
terraform_mode="apply"
terraform_args="$terraform_args -var do_token=$DO_API_TOKEN -state $tf_state_file"

if [ ! -z "$arg_test" ]; then
	terraform_mode="plan"
fi

if [ ! -z "$arg_destroy" ]; then
	terraform_args="$terraform_args -d"
	
	echo "Destroy resources? [y/N]"
	read destroy_confirm
	if [[ "$destroy_confirm" == "y" ]]; then
		echo "Failed to confirm destroy" >&2
		exit 1
	fi
fi


if ! terraform "$terraform_mode" $terraform_args; then
	echo "Error: Failed to run terraform $terraform_mode" >&2
	exit 1
fi
