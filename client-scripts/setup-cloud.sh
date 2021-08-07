#!/usr/bin/env bash
#?
# setup-cloud.sh - Setup cloud resources
#
# USAGE
#
#    setup-cloud.sh [-p,-y]
#
# OPTIONS
#
#    -p    Run in plan mode
#    -y    Do not confirm
#
# BEHAVIOR
#
#    Setup cloud resources with Terraform.
#
# ENVIRONMENT VARIABLES
#
#    DO_API_TOKEN             Digital Ocean API token
#    AWS_ACCESS_KEY_ID        AWS API access key ID
#    AWS_SECRET_ACCESS_KEY    AWS API secret access key
#
#?

# Configuration
prog_dir=$(realpath $(dirname "$0"))

terraform=terraform

configuration_dir=$(realpath "$prog_dir/../terraform")
plan_file=/tmp/funkyboy-zone.tf.plan
state_file=$(realpath "$prog_dir/../secret/terraform.tfstate")

# Helpers
function die() {
    echo "Error: $@" >&2
    exit 1
}

# Check for terraform CLI
if ! which $terraform &> /dev/null; then
    die "terraform must be installed"
fi

# Options
while getopts "py" opt; do
    case "$opt" in
	p) plan_only="true" ;;
	y) noconfirm="true" ;;
	'?') die "Unknown option" ;;
    esac
done

# Environment variables
# Check
if [ -z "$DO_API_TOKEN" ]; then
    die "DO_API_TOKEN must be set"
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    die "AWS_ACCESS_KEY_ID must be set"
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    die "AWS_SECRET_ACCESS_KEY must be set"
fi

# Set TF_VAR environment variables
export TF_VAR_do_token="$DO_API_TOKEN"

# Initialize terraform
if [ ! -d "$configuration_dir/.terraform" ]; then
    if ! terraform init "$configuration_dir"; then
	die "Failed to initialize terraform"
    fi
fi

# Plan
# Delete plan file if exists
if [ -f "$plan_file" ]; then
    echo "Deleting existing plan file"

    if ! rm "$plan_file"; then
	die "Failed to delete existing plan file"
    fi
fi

# Plan
if ! terraform plan \
     -out "$plan_file" \
     -state "$state_file" \
     "$configuration_dir"; then
    die "Failed to plan"
fi

# Exit if plan only given
if [ -n "$plan_only" ]; then
    echo "DONE"
    exit 0
fi

# Confirm plan
if [ -z "$noconfirm" ]; then
    echo "OK? [y/N]"

    read plan_confirm

    if [[ ! "$plan_confirm" =~ ^y|Y$ ]]; then
	die "Did not confirm"
    fi
fi

# Apply plan
if ! terraform apply \
     -state-out "$state_file" \
     "$plan_file"; then
    die "Failed to apply"
fi

echo "DONE"
