#!/usr/bin/env bash
#?
# setup-cloud.sh - Setup cloud resources
#
# USAGE
#
#    setup-cloud.sh [-p]
#
# OPTIONS
#
#    -p    (Optional) Run in plan mode
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

# {{{1 Configuration
prog_dir=$(realpath $(dirname "$0"))

terraform=terraform

configuration_dir=$(realpath "$prog_dir/../terraform")
plan_file=/tmp/funkyboy-zone.tf.plan
state_file=$(realpath "$prog_dir/../secret/terraform.tfstate")

# {{{1 Helpers
function die() {
    echo "Error: $@" >&2
    exit 1
}

# {{{1 Check for terraform CLI
if ! which $terraform &> /dev/null; then
    die "terraform must be installed"
fi

# {{{1 Options
while getopts "p" opt; do
    case "$opt" in
	p) plan_only="true" ;;
	'?') die "Unknown option" ;;
    esac
done

# {{{1 Environment variables
# {{{2 Check
if [ -z "$DO_API_TOKEN" ]; then
    die "DO_API_TOKEN must be set"
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    die "AWS_ACCESS_KEY_ID must be set"
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    die "AWS_SECRET_ACCESS_KEY must be set"
fi

# {{{2 Set TF_VAR environment variables
export TF_VAR_do_token="$DO_API_TOKEN"
export TF_VAR_aws_access_key_id="$AWS_ACCESS_KEY_ID"
export TF_VAR_aws_secret_access_key="$AWS_SECRET_ACCESS_KEY"

# {{{1 Initialize terraform
if [ ! -d "$configuration_dir/.terraform" ]; then
    if ! terraform init "$configuration_dir"; then
	die "Failed to initialize terraform"
    fi
fi

# {{{1 Plan
# {{{2 Delete plan file if exists
if [ -f "$plan_file" ]; then
    echo "Deleting existing plan file"

    if ! rm "$plan_file"; then
	die "Failed to delete existing plan file"
    fi
fi

# {{{2 Plan
if ! terraform plan \
     -out "$plan_file" \
     -state "$state_file" \
     "$configuration_dir"; then
    die "Failed to plan"
fi

# {{{2 Exit if plan only given
if [ -n "$plan_only" ]; then
    echo "DONE"
    exit 0
fi

# {{{2 Confirm plan
echo "OK? [y/N]"

read plan_confirm

if [[ ! "$plan_confirm" =~ ^y|Y$ ]]; then
    die "Did not confirm"
fi

# {{{1 Apply plan
if ! terraform apply \
     -state-out "$state_file" \
     "$plan_file"; then
    die "Failed to apply"
fi

echo "DONE"
