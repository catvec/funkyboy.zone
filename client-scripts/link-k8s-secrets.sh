#!/usr/bin/env bash
set -euo pipefail
readonly PROG_DIR=$(dirname $(realpath "$0"))
readonly SECRETS_SRC_DIR=$(realpath "${PROG_DIR}/../secret/kubernetes")
readonly SECRETS_DEST_DIR=$(realpath "${PROG_DIR}/../kubernetes")

readonly ACTION_LINK="link"
readonly ACTION_DIFF="diff"
readonly ACTION_UNLINK="unlink"
readonly ACTION_LIST="list"

# Options
OPT_DRY_RUN=""
OPT_FORCE=""
while getopts "hdf" opt; do
    case "$opt" in
        h)
            cat <<EOF
link-k8s-secrets.sh - Make symlinks of Kubernetes secret files from the secrets dir to the public dir

USAGE

  link-k8s-secrets.sh [-h] [-d] [-f] ACTION

OPTIONS

  -h    Show this help text and exit
  -d    Dry run
  -f    Overwrite existing files

ARGUMENTS

  ACTION    What action the script should take (default: '${ACTION_LINK}')

BEHAVIOR

  Actions can be:

    ${ACTION_LINK}: Link files from source to destination 
    ${ACTION_DIFF}: Show diff of source and destination files
    ${ACTION_UNLINK}: Remove destination files
    ${ACTION_LIST}: Print source and destination secret files

  Helps manage secret files from '${SECRETS_SRC_DIR}' to '${SECRETS_DEST_DIR}'. Files which already exist in the destination are ignored unless -f (force) is provided.

EOF
            exit 0
            ;;
        d) OPT_DRY_RUN="y" ;;
        f) OPT_FORCE="y" ;;
        '?')
            echo "Error: Unknown option" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

# Arguments
readonly ACTION="${1:-$ACTION_LINK}"
if [[ "$ACTION" != "$ACTION_LINK" ]] && [[ "$ACTION" != "$ACTION_DIFF" ]] && [[ "$ACTION" != "$ACTION_UNLINK" ]] && [[ "$ACTION" != "$ACTION_LIST" ]]; then
    echo "Error: Unknown action '$ACTION'" >&2
    exit 1
fi

# Loop over files
for src_file in $(find "$SECRETS_SRC_DIR" -type f); do
    agnostic_path=$(realpath --canonicalize-missing --relative-to="$SECRETS_SRC_DIR" "$src_file")
    dest_file="${SECRETS_DEST_DIR}/${agnostic_path}"
    
    case "$ACTION" in
        "$ACTION_LINK")
            echo "== $agnostic_path"
            
            # Determine if file should linked
            should_link=""
            if [[ ! -f "$dest_file" ]] || ([[ -f "$dest_file" ]] && [[ -n "$OPT_FORCE" ]]); then
                should_link="y"
            fi

            # Link files
            if [[ -z "$should_link" ]] && [[ -f "$dest_file" ]] && [[ -n "$OPT_FORCE" ]]; then
                if [[ -z "$OPT_DRY_RUN" ]]; then
                    rm "$dest_file"
                else
                    echo "  [dry run] rm '${dest_file}'"
                fi
                
                echo "  - overwriting destination file"
            fi

            if [[ -n "$should_link" ]]; then
                if [[ -z "$OPT_DRY_RUN" ]]; then
                    mkdir -p $(dirname "$dest_file")
                    ln -s "$src_file" "$dest_file"
                else
                    echo "  [dry run] ln -s '${src_file}' '${dest_file}'"
                fi

                echo "  + linked '${src_file}' to '${dest_file}'"
            else
                echo "  (already linked)"
            fi
            ;;
        "$ACTION_DIFF")
            echo "== $agnostic_path"
            if [[ -f "$dest_file" ]]; then
                set +e
                PAGER=cat diff --color "$src_file" "$dest_file"
                set -e
            else
                echo "Does not exist '${dest_file}'"
            fi
            ;;
        "$ACTION_UNLINK")
            echo "== $agnostic_path"
            if [[ -f "$dest_file" ]]; then
                if [[ -z "$OPT_DRY_RUN" ]]; then
                    echo "  [dry run] rm '${dest_file}'"
                else
                    rm "${dest_file}"
                fi
            else
                echo "  (already deleted)"
            fi
            ;;
        "$ACTION_LIST")
            echo "${agnostic_path} ${src_file} ${dest_file}"
            ;;
    esac
done
