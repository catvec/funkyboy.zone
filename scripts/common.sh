# Common bash helper functions used by scripts in the repository

set -o pipefail

# Constants
declare -ri TRUE=0
declare -ri FALSE=1

# Output the date, time, and $msg to stdout.
log() { # ( msg )
    local -r msg="$1"
    
    echo "$(date) $msg"
}

# Output date, time, and $msg to stderr.
elog() { # ( msg )
    local -r msg="$1"

    log "$msg" >&2
}

# Print $msg to stderr and exit with $code.
die() { # ( code, msg )
    local -ri code="$1"
    local -r msg="$2"

    elog "$msg"
    exit $code
}

# Runs the command $cmd. If this fails then prints information about the failed command and $failure_exit_msg to stderr and exits with $failure_exit_code. 
run_check() { # ( cmd, failure_exit_code, failure_exit_msg )
    local -r cmd="$1"
    local -ri failure_exit_code="$2"
    local -r failure_exit_msg="$3"

    if ! eval "$cmd"; then
	   elog "Failed to run"
	   elog "    Command  : '$cmd'"
	   elog "    Directory: '$(pwd)'"
	   die $failure_exit_code "$failure_exit_msg"
    fi
}

# Join an $array with a $delimiter.
join_arr() { # ( $delimiter, $array )
    # Arguments
    local -r delimiter="$1"
    shift
    local -ra array=("$@")

    # Join
    local out=""

    if ((${#array[@]} == 0)); then
	   return
    fi

    local -i i=0
    for item in "${array[@]}"; do
	   if (($i != 0)); then
		  out+=$(echo -e "$delimiter")
	   fi

	   out+="$item"
	   
	   i=$(($i + 1))
    done

    echo "$out"
}

# Reads stdin and ensures each line is indented by $indent. Outputs indented result.
indent_lines() { # ( indent )
    # Arguments
    local -r indent="$1"

    # Indent
    while read -r line; do
	   echo "${indent}${line}"
    done
}

# Prints an error message and returns $FALSE if any of the provided $bins cannot be found in the $PATH.
ensure_bins() { # ( bins )
    # Arguments
    local -ra bins=("$@")

    # Check
    local -a missing_bins=()
    for bin in "${bins[@]}"; do
	   if ! which "$bin" &> /dev/null; then
		  missing_bins+=("$bin")
	   fi
    done

    if ((${#missing_bins[@]} > 0)); then
	   local -a missing_bins_str
	   missing_bins_str=$(join_arr ", " "${missing_bins[@]}") || exit
	   
	   elog "Missing program(s): $missing_bins_str"
	   return $FALSE
    fi
}
