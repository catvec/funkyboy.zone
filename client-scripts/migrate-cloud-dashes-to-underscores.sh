#!/usr/bin/env bash
die() {
    echo "Error: $@" >&2
    exit 1
}

check() {
    if [[ "$?" != "0" ]]; then
	   die "$@"
    fi
}

terraform_args=()
while getopts "ht" opt; do
    case "$opt" in
	   h)
		  cat <<EOF
migrate-cloud-dashes-to-underscores.sh - Migrate terraform resources with dashes in their names to names with underscores.

USAGES

    migrate-cloud-dashes-to-underscores.sh

OPTIONS

    -h    Show help text.
    -t    Show what will be run without running it.
EOF
		  exit 0
		  ;;
	   t) terraform_args+=(-dry-run) ;;
	   ?) die "Unknown option" ;; 
    esac
done

prog_dir=$(realpath $(dirname "$0"))
configuration_dir=$(realpath "$prog_dir/../terraform")
state_file=$(realpath "$prog_dir/../secret/terraform.tfstate")

terraform_args+=(-state "$state_file")
ignore_resources=(
    "aws_route53_record.4e48-dev-personal-website-acm-proof"
    "aws_route53_record.4e48-dev-personal-website-apex"
    "aws_route53_record.4e48-dev-personal-website-wildcard"
    "aws_route53_zone.4e48-dev"
)

while read -r resource; do
    ignore_this_resource=""
    for ignore_resource in "${ignore_resources[@]}"; do
	   if echo "$resource" | grep "$ignore_resource" &> /dev/null; then
		  ignore_this_resource=true
		  break
	   fi
    done

    if [ -n "$ignore_this_resource" ]; then
	   echo "Skipping \"$resource\""
	   continue
    fi
    
    dashed_resource=$(echo "$resource" | sed 's/-/_/g')
    check "Failed to convert resource name \"$resource\" to a name with underscores"

    terraform state mv ${terraform_args[@]} "$resource" "$dashed_resource"
    check "Failed to rename resource \"$resource\" to \"$dashed_resource\""
done <<<$(terraform state list -state "$state_file" | grep -)
