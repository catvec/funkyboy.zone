#!/usr/bin/env bash

readonly ERR_CODE_DIE_ARG_CODE_MISSING=100
readonly ERR_CODE_ENSURE_ARG_NAME_MISSING=101
readonly ERR_CODE_ENSURE_ARG_VALUE_MISSING=102
readonly ERR_CODE_ENSURE_ARG_CALLER_ARG_MISSING=103

readonly ERR_CODE_UNKNOWN_OPT=110

readonly ERR_CODE_NO_TERRAFORM_BIN=120
readonly ERR_CODE_MISSING_ENV_VAR=121

readonly ERR_CODE_TERRAFORM_INIT=130
readonly ERR_CODE_TERRAFORM_PLAN=131
readonly ERR_CODE_TERRAFORM_APPLY=132

readonly ERR_CODE_RM_EXISTING_PLAN=140
readonly ERR_CODE_RUN_PLAN_CONFIRM=141

# Configuration
prog_dir=$(realpath $(dirname "$0"))

terraform=terraform

configuration_dir=$(realpath "$prog_dir/../terraform")
plan_file=/tmp/funkyboy-zone.tf.plan
state_file=$(realpath "$prog_dir/../secret/terraform.tfstate")

# Helpers
# Exit with code and message
die() { # (code, msg...)
    local code="$1"
    shift
    if [ -z "$code" ]; then
	   echo "Error: die: code argument must be provided"
	   echo "Error: $@" >&2
	   exit "$ERR_CODE_DIE_ARG_CODE_MISSING"
    fi
    
    echo "Error: $@" >&2
    exit "$code"
}

# Ensures an argument for a function exists and returns it if it does, or exits.
ensure_arg() { # (name, value...)
    # Arguments
    local name="$1"
    shift
    if [ -z "$name" ]; then
	   die "$ERR_CODE_ENSURE_ARG_NAME_MISSING" "ensure_arg: name argument required, could not ensure arg for caller"
    fi

    local value="$@"
    if [ -z "$value" ]; then
	   die "$ERR_CODE_ENSURE_ARG_VALUE_MISSING" "ensure_arg: value argument required, could not ensure arg for caller"
    fi

    # Ensure arguments
    if [ -z "$value" ]; then
	   die "$ERR_CODE_ENSURE_ARG_CALLER_ARG_MISSING" "${FUNCNAME[0]}: $name argument must be provided"
    fi

    echo "$value"
}

# Check if the last command failed, if so die with args
check() { # (code, fail msg)
    last_status="$?"
    
    local code=$(ensure_arg "code" "$1")
    shift
    local fail_msg=$(ensure_arg "fail_msg" "$1")

    if [[ "$last_status" != "0" ]]; then
	   echo "Traceback: $(echo ${FUNCNAME[@]:1} | sed 's/ / < /')"
	   die "$code" "$fail_msg"
    fi
}

# Check for terraform CLI
if ! which $terraform &> /dev/null; then
    die "$ERR_CODE_NO_TERRAFORM_BIN" "terraform must be installed"
fi

# Options
while getopts "hpy" opt; do
    case "$opt" in
	   h)
		  cat <<EOF
setup-cloud.sh - Setup cloud resources

USAGE

    setup-cloud.sh [-p,-y]

OPTIONS

   -p    Run in plan mode
   -y    Do not confirm

BEHAVIOR

   Setup cloud resources with Terraform.

 ENVIRONMENT VARIABLES

   DO_API_TOKEN             Digital Ocean API token
   AWS_ACCESS_KEY_ID        AWS API access key ID
   AWS_SECRET_ACCESS_KEY    AWS API secret access key

EOF
		  exit 0
	   ;;
	   p) plan_only="true" ;;
	   y) noconfirm="true" ;;
	   '?') die "$ERR_CODE_UNKNOWN_OPT" "Unknown option" ;;
    esac
done

# Environment variables
# Check
missing_env_vars=()
for env in DO_API_TOKEN AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY; do
    if [ -z "${!env}" ]; then
	   missing_env_vars+=("$env")
    fi
done

if (( ${#missing_env_vars[@]} > 0 )); then
    die "$ERR_CODE_MISSING_ENV_VAR" "${missing_env_vars[@]} environment variable must be set"
fi

# Set TF_VAR environment variables
export TF_VAR_do_token="$DO_API_TOKEN"

# Initialize terraform
if [ ! -d "$configuration_dir/.terraform" ]; then
    terraform -chdir="$configuration_dir" init
    check "$ERR_CODE_TERRAFORM_INIT" "Failed to initialize terraform"
fi

# Plan
# Delete plan file if exists
if [ -f "$plan_file" ]; then
    echo "Deleting existing plan file"

    rm "$plan_file"
    check "$ERR_CODE_RM_EXISTING_PLAN" "Failed to delete existing plan file"
fi

# Plan
terraform -chdir="$configuration_dir" plan \
		-out "$plan_file" \
		-state "$state_file"
		
check "$ERR_CODE_TERRAFORM_PLAN" "Failed to plan"

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
	   die "$ERR_CODE_RUN_PLAN_CONFIRM" "Did not confirm"
    fi
fi

# Apply plan
terraform -chdir="$configuration_dir" apply \
		-state-out "$state_file" \
		"$plan_file"
check "$ERR_CODE_TERRAFORM_APPLY" "Failed to apply"

echo "DONE"
