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

# Outputs a help message. Arguments are passed in via global environment variables since multiple arrays arguments are required and this is not possible with bash.
# $HELP_SCRIPT is the name of the script file.
# $HELP_SCRIPT_BLURB is a short sentence describing the script.
# $HEPL_OPTIONS is an array of option letters. Place a question mark after the letter to indicate it is optional (ex., 'a?'). If the option takes a value add a colon then the name of the value as it should be shown in the help (ex., 'a:AIRPLANE' would result in the help text '-a AIRPLANE'). If an option is optional and required a value put the question mark before the colon.
# $HELP_OPTION_BLURBS are the help texts corresponding to each option at the same index in $HELP_OPTIONS.
# $HELP_BEHAVIOR is an optional paragraph that will be included at the bottom of the message.
generate_help_msg() {
    # Parsed option specification information:
    # option_letter - The single letter for an option
    option_letters=()
    
    # if_meta_arg_exists_for_options - Contains an index for each $HELP_OPTIONS item, if 'y' then this option has a meta argument, if 'n' then it does not.
    # meta_args_for_options - Contains a key for each $HELP_OPTIONS item, the key will be the meta argument for an option, or '_' if the option does not have a meta argument.
    local -a if_meta_args_exist_for_options=()
    local -a meta_args_for_options=()

    # if_option_optional - Contains a key for each $HELP_OPTIONS item, if 'y' the option is optional, if 'n' the option is not options.
    local -a if_option_optional=()

    # longest_meta_arg - The length of the longest meta argument of all the options, used for spacing.
    local -i longest_meta_arg=0

    # Parse option specifications
    local -i opt_i=0

    for opt in "${HELP_OPTIONS[@]}"; do
	   # Get letter of option
	   local opt_letter
	   opt_letter=$(sed 's/^\(.\).*$/\1/g' <<< "$opt") || exit

	   option_letters+=("$opt_letter")
	   
	   # Check if optional
	   local is_optional=""
	   if grep "?" <<< "$opt" &> /dev/null; then
		  is_optional="t"
		  if_option_optional+=("y")
	   else
		  if_option_optional+=("n")
	   fi

	   # Get meta arg name
	   local meta_arg_name=""
	   if grep ":" <<< "$opt" &> /dev/null; then
		  if [[ -n "$is_optional" ]]; then
			 # Use regex for the optional option specification format (includes '?')
			 meta_arg_name=$(sed 's/^.*:\(.*\)$/\1/g' <<< "$opt") || exit
		  else
			 # Use regex for non-optional option specification format (no '?')
			 meta_arg_name=$(sed 's/^.:\(.*\)$/\1/g' <<< "$opt") || exit
		  fi
	   fi

	   if [[ -n "$meta_arg_name" ]]; then
		  if_meta_arg_exists_for_options+=("y")
		  meta_args_for_options+=("$meta_arg_name")
	   else
		  if_meta_arg_exists_for_options+=("n")
		  meta_args_for_options+=("_")
	   fi

	   # ... Find longest meta argument
	   if ((${#meta_arg_name} > $longest_meta_arg)); then
		  longest_meta_arg=${#meta_arg_name}
	   fi
	   
	   opt_i=$(($opt_i + 1))
    done

    # Create usage help strings
    # USAGE section variables:
    # Each variable is an array of strings, where each string represents how the option should be passed into the script
    # usage_options_required - Holds strings for required options.
    # usage_options_optional - Holds strings for optional options.
    local -a usage_options_required=()
    local -a usage_options_optional=()

    # OPTIONS section variables:
    # options_options_repr - For each option shows how the option should be passed to the script.
    local -a options_options_repr=()
    
    opt_i=0
    while (($opt_i < ${#HELP_OPTIONS[@]})); do
	   # USAGE section help string
	   # ... Generate
	   local usage_opt_str="-${option_letters[$opt_i]}"

	   if [[ "${if_meta_arg_exists_for_options[$opt_i]}" == "y" ]]; then
		  usage_opt_str+=" $meta_arg_name"
	   fi

	   # ... Record
	   if [[ "${if_option_optional[$opt_i]}" == "n" ]]; then
		  # Required
		  usage_options_required+=("$usage_opt_str")
	   else
		  # Optional
		  usage_options_optional+=("$usage_opt_str")
	   fi

	   # OPTIONS section help string
	   local option_blurb_meta_arg_str=" "
	   if [[ "${if_meta_arg_exists_for_options[$opt_i]}" == "y" ]]; then
		  option_blurb_meta_arg_str=" $meta_arg_name"
	   fi

	   # ... Ensure OPTIONS section appears with even column formatting
	   local longest_meta_arg_spacing=""
	   local -i meta_arg_length=0
	   
	   if [[ "${if_meta_arg_exists_for_options[$opt_i]}" == "y" ]]; then
		  local -r meta_arg_name="${meta_args_for_options[$opt_i]}"
		  meta_arg_length=${#meta_arg_name}
	   fi

	   # ... + 2 so there are 2 spaces between option name and option help blurb
	   while ((${#longest_meta_arg_spacing} < ($longest_meta_arg + 2 - $meta_arg_length))); do
		  longest_meta_arg_spacing+=" "
	   done
	   
	   local blurb="${HELP_OPTION_BLURBS[$opt_i]}"
	   if [[ "${if_option_optional[$opt_i]}" == "y" ]]; then
		  # Add '(Optional)' onto the end of a help blurb if it is optional
		  blurb+=" (Optional)"
	   fi

	   # ... Record
	   options_options_repr+=("-${option_letters[$opt_i]}${option_blurb_meta_arg_str}${longest_meta_arg_spacing}${blurb}")

	   opt_i=$(($opt_i + 1))
    done

    # ... Flatten USAGE section arrays into strings
    local usage_options_required_str
    usage_options_required_str=$(join_arr "," "${usage_options_required[@]}") || exit
    
    local usage_options_optional_str
    usage_options_optional_str=$(join_arr "," "${usage_options_optional[@]}") || exit

    # ... ... Ensure appropriate spacing around these strings
    if ((${#usage_options_required[@]} > 0)); then
	   usage_options_required_str=" $usage_options_required_str"
    fi

    if ((${#usage_options_optional[@]} > 0)); then
	   usage_options_optional_str=" [$usage_options_optional_str]"
    fi

    # ... Template OPTIONS section values into something to be printed out
    local options_help_block=""

    if ((${#HELP_OPTIONS[@]} > 0)); then	   
	   options_help_block=$(cat <<EOF


OPTIONS

  $(join_arr "\n  " "${options_options_repr[@]}")
EOF
					 )
    fi

    # ... BEHAVIOR section
    local behavior_block=""
    if [[ -n "$HELP_BEHAVIOR" ]]; then
	   behavior_block=$(cat <<EOF


BEHAVIOR

$(indent_lines "  " <<< "$HELP_BEHAVIOR")
 
EOF
					)
    fi
    
    # Output help block
    cat <<EOF
$HELP_SCRIPT - $HELP_SCRIPT_BLURB

USAGE

  ${HELP_SCRIPT}${usage_options_required_str}${usage_options_optional_str}${options_help_block}${behavior_block}
EOF
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
