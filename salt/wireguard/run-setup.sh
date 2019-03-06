#!/usr/bin/env bash
#?
# run-setup.sh - Run setup.sh with required options
# 
# USAGE
#
#	run-setup.sh
#
# BEHAVIOR
#
# 	Runs setup.sh with the required options.
#
#?

exec {{ pillar.wireguard.setup_script }} \
	-i {{ pillar.wireguard.interface.name }} \
	-a {{ pillar.wireguard.interface.address }} \
	-k {{ pillar.wireguard.private_key_file }}
