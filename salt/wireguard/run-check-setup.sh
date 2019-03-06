#!/usr/bin/env bash
#?
# run-check-setup.sh - Run check-setup.sh with required options
# 
# USAGE
#
#	run-check-setup.sh
#
# BEHAVIOR
#
# 	Runs check-setup.sh with the required options.
#
#?

exec {{ pillar.wireguard.check_setup_script }} \
	-i {{ pillar.wireguard.interface.name }} \
	-a {{ pillar.wireguard.interface.address }}
