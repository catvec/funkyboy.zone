#!/usr/bin/env bash
declare -r PROG_DIR=$(realpath $(dirname "$0"))

# Exit codes
declare -ri EXIT_CODE_UNKNOWN_OPT=10
declare -r EXIT_MSG_UNKNOWN_OPT="Unknown option"

declare -ri EXIT_CODE_DOWNLOAD=11
declare -r EXIT_MSG_DOWNLOAD="Failed to download ArgoCD operator subscription manifest."

# Common
source "$PROG_DIR/../../../../scripts/common.sh"

declare -r HELP_SCRIPT="re-download-argocd-operator-subscription-manifest.sh"
declare -r HELP_SCRIPT_BLURB="Re-downloads the ArgoCD operator subscription"
declare -ra HELP_OPTIONS=("h?")
declare -ra HELP_OPTION_BLURBS=("Show help text")
declare -r HELP_BEHAVIOR="Downloads the ArgoCD operator OLM subscription manifest from the OperatorHub website"

# Constants
declare -r MANIFEST_URL="https://operatorhub.io/install/argocd-operator.yaml"
declare -r MANIFEST_OUT="$PROG_DIR/../resources/argocd-operator-subscription.yaml"

# Options
while getopts "h" opt; do
    case "$opt" in
	   h)
		  generate_help_msg
		  exit 0
		  ;;
	   '?') die "$EXIT_CODE_UNKNOWN_OPT" "$EXIT_MSG_UNKNOWN_OPT" ;;
    esac
done

# Download
log "Downloading ArgoCD operator OLM subscription"
run_check "curl -L '$MANIFEST_URL' -o '$MANIFEST_OUT'" "$EXIT_CODE_DOWNLOAD" "$EXIT_MSG_DOWNLOAD"
log "Success"
