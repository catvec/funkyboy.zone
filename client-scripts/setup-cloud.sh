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
tf_plan_file=/tmp/funkyboy-zone-tf-plan

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

# {{{1 Plan
# {{{2 Check for existing plan
if [ -f "$tf_plan_file" ]; then
	# {{{3 Check if we should delete plan
	echo "Existing plan ($tf_plan_file) found, overwrite? [y/N] "
	read plan_overwrite

	if [[ "$plan_overwrite" == "y" || "$plan_overwrite" == "Y" ]]; then
		# Delete existing plan
		if ! rm "$tf_plan_file"; then
			echo "Error: Failed to delete existing plan: \"$tf_plan_file\"" >&2
			exit 1
		fi

		echo "Delete plan ($tf_plan_file)"
	fi
fi

# {{{2 Run plan
if [ ! -f "$tf_plan_file" ]; then
	terraform_plan_args="$terraform_plan_args -var do_token=$DO_API_TOKEN -state $tf_state_file -out $tf_plan_file"

	if [ ! -z "$arg_destroy" ]; then
		terraform_plan_args="$terraform_plan_args -destroy"
	fi

	if ! terraform plan $terraform_plan_args; then
		echo "Error: Failed to plan" >&2
		exit 1
	fi
fi

# {{{2 Check if we are only planning
if [ ! -z "$arg_test" ]; then
	echo "Test mode complete"
	exit 0
fi

# {{{1 Apply
# {{{2 If destroying resources, confirm
if [ ! -z "$arg_destroy" ]; then
	echo "Destroy resources? [y/N]"
	read destroy_confirm

	if [[ "$destroy_confirm" != "y" && "$destroy_confirm" != "Y" ]]; then
		echo "Failed to confirm destroy" >&2
		exit 1
	fi
fi

# {{{2 Apply
if ! terraform apply "$tf_plan_file"; then
	echo "Error: Failed to run terraform $terraform_mode" >&2
	exit 1
fi

# {{{2 Remove plan
if ! rm "$tf_plan_file"; then
	echo "Error: Failed to delete applied plan: \"$tf_plan_file\"" >&2
	exit 1
fi

echo "DONE"
