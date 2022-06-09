#!/usr/bin/env bash
declare -r PROG_DIR=$(realpath $(dirname "$0"))

# Exit codes
declare -ri EXIT_CODE_UNKNOWN_OPT=10
declare -r EXIT_MSG_UNKNOWN_OPT="Unknown option"

declare -ri EXIT_CODE_MISSING_HELM=11
declare -r EXIT_MSG_MISSING_HELM="The 'helm' program must be installed"

declare -ri EXIT_CODE_HELM_TEMPLATE=12
declare -r EXIT_MSG_HELM_TEMPLATE="Failed to expand Helm chart into plain manifest files"

# Common
source "$PROG_DIR/../../../../scripts/common.sh"

declare -r HELP_SCRIPT="render-chart.sh"
declare -r HELP_SCRIPT_BLURB="Expand the Teleport chart into plain manifest files"
declare -ra HELP_OPTIONS=("h?")
declare -ra HELP_OPTION_BLURBS=("Show help text")
declare -r HELP_BEHAVIOR=$(cat <<EOF
Takes the Teleport chart and uses Helm to compute the resulting manifest results for the chart.

The 'helm' program must be installed and accessible via the \$PATH.

EOF
	   )

# Constants
declare -r HELM_CHART_PATH="$PROG_DIR/../resources/teleport/examples/chart/teleport-cluster"
declare -r HELM_CHART_VALUES_FILE="$PROG_DIR/../resources/teleport-chart-values.yaml"
declare -r HELM_CHART_RELEASE_NAME="teleport-cluster"
declare -r MANIFEST_OUT="$PROG_DIR/../resources/teleport-cluster.yaml"

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

# Ensure binaries exist
run_check "ensure_bins helm" "$EXIT_CODE_MISSING_HELM" "$EXIT_MSG_MISSING_HELM"

# Expand chart
log "Rendering Teleport chart into '$MANIFEST_OUT' manifest file"
run_check "helm template --values '$HELM_CHART_VALUES_FILE' --name-template '$HELM_CHART_RELEASE_NAME' '$HELM_CHART_PATH' > '$MANIFEST_OUT'" "$EXIT_CODE_HELM_TEMPLATE" "$EXIT_MSG_HELM_TEMPLATE"
log "Done"
