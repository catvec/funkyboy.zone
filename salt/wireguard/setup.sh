#!/usr/bin/env bash
#?
# setup.sh - Setup Wireguard interface
#
# USAGE
#
#	setup.sh OPTIONS
#
# OPTIONS
#
#	-i I_NAME      Name of interface to create
#	-a I_ADDR      Address to attach to Wireguard interface
#	-c I_CONF_F    Wireguard configuration file
#
# BEHAVIOR
#
#	Sets up a Wireguard interface.
#
#?

# {{{1 Exit on any error
set -e

# {{{1 Options
# {{{2 Get
while getopts "i:a:c:" opt; do
	case "$opt" in
		i)
			interface_name="$OPTARG"
			;;

		a)
			interface_address="$OPTARG"
			;;

		c)
			interface_config_file="$OPTARG"
			;;

		'?')
			echo "Error: Unknown option \"$opt\"" >&2
			exit 1
			;;
	esac
done

# {{{2 Verify
# {{{3 interface_name
if [ -z "$interface_name" ]; then
	echo "Error: -i I_NAME option required" >&2
	exit 1
fi

# {{{3 interface_address
if [ -z "$interface_address" ]; then
	echo "Error: -a I_ADDR option required" >&2
	exit 1
fi

# {{{3 interface_config_file
if [ -z "$interface_config_file" ]; then
	echo "Error: -c I_CONF_F option required" >&2
	exit 1
fi

# {{{1 Create interface
if ! ip link add "$interface_name" type wireguard; then
	echo "Error: Failed to create $interface_name interface" >&2
	exit 1
fi

# {{{1 Attach address to interface
if ! ip addr add "$interface_address" dev "$interface_name"; then
	echo "Error: Failed to attach $interface_address to $interface_name interface" >&2
	exit 1
fi

# {{{1 Set configuration for interface
if ! wg setconf "$interface_name" "$interface_config_file"; then
	echo "Error: Failed to set configuration file $interface_config_file for $interface_name" >&2
	exit 1
fi

# {{{1 Set interface up
if ! ip link set "$interface_name" up; then
	echo "Error: Failed to set $interface_name to up" >&2
	exit 1
fi
