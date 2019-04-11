#!/usr/bin/env bash
#?
# setup.sh - Setup Wireguard interface
#
# USAGE
#
#    setup.sh OPTIONS
#
# OPTIONS
#
#    -i IFACE    Name of interface
#    -c CFG      Configuration file
#    -u          Check if running interface's configuration is up to date
#
# BEHAVIOR
#
#    Set up Wireguard interface from configuration file.
#
#    If the -u option is provided will exit with non-zero exit code if
#    the interface is not up to date
#
#?

# {{{1 Helpers
function die() {
    echo "Error: $@" >&2
    exit 1
}

# {{{1 Options
# {{{2 Get
while getopts "i:c:u" opt; do
    case "$opt" in
	i) interface="$OPTARG" ;;
	c) config_file="$OPTARG" ;;
	u) up_to_date_mode="true" ;;
	'?') die "Unknown option"
    esac
done

# {{{2 Verify
# {{{3 interface
if [ -z "$interface" ]; then
    die "-i IFACE option required"
fi

# {{{3 config_file
if [ -z "$config_file" ]; then
    die "-c CFG option required"
fi

if [ ! -f "$config_file" ]; then
    die "-c CFG file does not exist"
fi

# {{{1 Up to date mode
if [ -n "$up_to_date_mode" ]; then
    echo "up to date mode"
    
    # {{{2 Check if interface is running
    if ! wg show "$interface" &> /dev/null; then
	echo "interface does not exist"
	exit 1
    fi

    # {{{2 Get existing configuration
    existing_conf_file="/tmp/existing.$interface.conf"
    expected_conf_file="/tmp/expected.$interface.conf"
    cleanup_files=("$existing_conf_file" "$expected_conf_file")

    function cleanup() {
	for f in "${cleanup_files[@]}"; do
	    if [ ! -f "$f" ]; then
		continue
	    fi

	    if ! rm "$f"; then
		die "Failed to cleanup $f file"
	    fi
        done
    }
    trap cleanup EXIT

    if ! wg showconf "$interface" | sed '/\(Address\|AllowedIPs\|Endpoint\).*/d' | sed '/^$/d' | tee "$existing_conf_file" &> /dev/null; then
	die "Failed to get $interface configuration"
    fi

    if ! cat "$config_file" | sed '/\(Address\|AllowedIPs\|Endpoint\).*/d' | sed '/^$/d' | tee "$expected_conf_file" &> /dev/null; then
	die "Failed to clean $conf_file configuration file"
    fi

    # {{{2 Compare configuration
    if ! git diff --no-index "$existing_conf_file" "$expected_conf_file"; then
	echo "configuration does not match"
	exit 1
    fi

    echo "interface $interface is up to date"
    exit 0
fi

# {{{1 Regular mode
# {{{2 Delete interface if already exists
if wg show "$interface" &> /dev/null; then
    if ! wg-quick down "$interface"; then
	die "Failed to bring existing inteface $interface down"
    fi
fi

# {{{2 Bring interface up
if ! wg-quick up "$config_file"; then
    die "Failed to bring interface $interface up"
fi

echo "brought up interface $interface"
