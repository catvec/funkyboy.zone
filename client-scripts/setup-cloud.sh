#!/usr/bin/env bash

readonly ERR_CODE_DIE_ARG_CODE_MISSING=100
readonly ERR_CODE_ENSURE_ARG_NAME_MISSING=101
readonly ERR_CODE_ENSURE_ARG_VALUE_MISSING=102
readonly ERR_CODE_ENSURE_ARG_CALLER_ARG_MISSING=103

readonly ERR_CODE_UNKNOWN_OPT=110

readonly ERR_CODE_NO_TERRAFORM_BIN=120
readonly ERR_CODE_MISSING_ENV_VAR=121
readonly ERR_CODE_GET_DATA_RESOURCES=125
readonly ERR_CODE_GET_DATA_RESOURCES_COUNT=126

readonly ERR_CODE_TERRAFORM_INIT=130
readonly ERR_CODE_TERRAFORM_PLAN=131
readonly ERR_CODE_TERRAFORM_APPLY=132

readonly ERR_CODE_RM_EXISTING_PLAN=140
readonly ERR_CODE_RUN_PLAN_CONFIRM=141

readonly ERR_CODE_APPLY_MAIN_TERRAFORM_PROJECT=150
readonly ERR_CODE_APPLY_KUBERNETES_TERRAFORM_PROJECT=151

# Configuration
prog_dir=$(realpath $(dirname "$0"))

terraform=terraform

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
while getopts "hipy" opt; do
    case "$opt" in
	   h)
		  cat <<EOF
setup-cloud.sh - Setup cloud resources

USAGE

    setup-cloud.sh [-h,-i,-p,-y] [project]

OPTIONS

    -h    Show help text
    -i    Force a terraform initialization
    -p    Run in plan mode
    -y    Do not confirm

ARGUMENTS

    project    The name of the Terraform project to apply, if specified only this project will be applied

BEHAVIOR

    Setup cloud resources with Terraform.

 ENVIRONMENT VARIABLES

    DO_API_TOKEN             Digital Ocean API token
    AWS_ACCESS_KEY_ID        AWS API access key ID
    AWS_SECRET_ACCESS_KEY    AWS API secret access key

EOF
		  exit 0
		  ;;
	   i) force_tf_init=true ;;
	   p) plan_only=true ;;
	   y) noconfirm=true ;;
	   '?') die "$ERR_CODE_UNKNOWN_OPT" "Unknown option" ;;
    esac
done

shift $((OPTIND-1))

# Arguments
readonly arg_project="$1"

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

# Gets resources which are data resources
get_data_resources() { # ( state_file )
    local -r state_file="$1"

    jq '.resources[] | select(.mode == "data") | . as $instance | $instance.instances[] | $instance.module + "." + $instance.mode + "." + $instance.type + "." + $instance.name' < "$state_file" | tr '\n' ' '
}

# Gets count of resources from get_data_resources
get_data_resources_count() { # ( state_file )
    local -r state_file="$1"

    jq '.resources[] | select(.mode == "data") | . as $instance | $instance.instances[] | length' < "$state_file" | tr '\n' ' '
}

# project_directory = Name of the project directory relative to the repository root
# If data_only_resources argument is set then only resource which are of mode "data" will be applied
apply_tf_project() { # ( project_directory, [ data_only_resources ] )
    # Arguments
    local -r project_dir="$1"
    local -r data_only_resources="$2"

    # Terraform directories for project
    local -r project_name=$(echo "$project_dir" | sed 's/\//-/g')
    
    local -r configuration_dir=$(realpath "$prog_dir/../$project_dir")
    local -r plan_file="/tmp/$project_name.tf.plan"
    local -r state_file=$(realpath "$prog_dir/../secret/$project_name.tfstate")

    # Initialize terraform
    if [ ! -d "$configuration_dir/.terraform" ] || [ -n "$force_tf_init" ]; then
	   terraform -chdir="$configuration_dir" init -upgrade
	   check "$ERR_CODE_TERRAFORM_INIT" "Failed to initialize terraform (project: $project_dir)"
    fi

    # Plan
    # Delete plan file if exists
    if [ -f "$plan_file" ]; then
	   echo "Deleting existing plan file '$plan_file' (project: $project_dir)"

	   rm "$plan_file"
	   check "$ERR_CODE_RM_EXISTING_PLAN" "Failed to delete existing plan file (project: $project_dir)"
    fi

    # Create -target options
    target_opts=()
    if [[ -n "$data_only_resources" ]]; then
	   local -r data_resources=$(get_data_resources "$state_file") || exit
	   check "$ERR_CODE_GET_DATA_RESOURCES" "Failed to find data only resources"

	   local -r data_resources_arr=($data_resources)

	   local -r data_resources_counts=$(get_data_resources_count "$state_file") || exit
	   check "$ERR_CODE_GET_DATA_RESOURCES_COUNT" "Failed to find data only resources counts"

	   local -r data_resources_counts_arr=($data_resources_counts)

	   local -i resource_i=0
	   
	   local -i instance_i
	   local -i number_of_this_resource
	   for resource in "${data_resources_arr[@]}"; do
		  instance_i=0
		  number_of_this_resource=${data_resources_counts_arr[$resource_i]}

		  while (($instance_i < $number_of_this_resource)); do
			 resource_str=$(sed 's/"//g' <<< "$resource")
			 target_opts+=("-target=$resource_str[$instance_i]")
			 echo "$resource_str[$instance_i]"

			 instance_i=$(($instance_i + 1))
		  done

		  resource_i=$(($resource_i + 1))
	   done
	   exit 0
    fi

    # Plan
    terraform -chdir="$configuration_dir" plan \
		    -out "$plan_file" \
		    -state "$state_file" "${target_opts[@]}"

    check "$ERR_CODE_TERRAFORM_PLAN" "Failed to plan (project: $project_dir)"

    # Exit if plan only given
    if [ -n "$plan_only" ]; then
	   echo "DONE (project: $project_dir)"
	   exit 0
    fi

    # Confirm plan
    if [ -z "$noconfirm" ]; then
	   echo "OK? [y/N] (project: $project_dir)"

	   read plan_confirm

	   if [[ ! "$plan_confirm" =~ ^y|Y$ ]]; then
		  die "$ERR_CODE_RUN_PLAN_CONFIRM" "Did not confirm (project: $project_dir)"
	   fi
    fi

    # Apply plan
    terraform -chdir="$configuration_dir" apply \
		    -state-out "$state_file" \
		    -state "$state_file" \
		    "$plan_file"
    check "$ERR_CODE_TERRAFORM_APPLY" "Failed to apply (project: $project_dir)"

    echo "DONE (project: $project_dir)"
}

if [[ "$arg_project" == "terraform" ]] || [[ -z "$arg_project" ]]; then
    apply_tf_project "terraform"
    check "$ERR_CODE_APPLY_MAIN_TERRAFORM_PROJECT" "Failed to apply main Terraform project"
fi

if [[ "$arg_project" == "terraform/kubernetes-terraform" ]] || [[ -z "$arg_project" ]]; then
    apply_tf_project "terraform/kubernetes-terraform" "y"
    apply_tf_project "terraform/kubernetes-terraform"
    check "$ERR_CODE_APPLY_KUBERNETES_TERRAFORM_PROJECT" "Failed to apply Kubernetes Terraform project"
fi
