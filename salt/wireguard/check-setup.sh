#!/usr/bin/env bash
#?
# check-setup.sh - Checks if Wireguard interface has been setup yet
#
# USAGE
#
#	check-setup.sh OPTIONS
#
# OPTIONS
#
#	-i I_NAME    Wireguard interface name
#	-a I_ADDR    Address to attach to Wireguard interface
#
# BEHAVIOR
#
#	Checks if an interface exists with correct address.
#
#?

# {{{1 Exit on any error
set -e

# {{{1 Options
# {{{2 Get
while getopts "i:a:" opt; do
	case "$opt" in
		i)
			interface_name="$OPTARG"
			;;

		a)
			interface_address="$OPTARG"
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

# {{{1 Check if interface exists with correct address
if ! ip addr show | grep "inet ${interface_address}.*${interface_name}"; then
	echo "Does not exist with correct address"
	exit 1
fi
