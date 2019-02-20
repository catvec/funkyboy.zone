#!/usr/bin/env bash
#?
# should_build.sh - Check if the Node Exporter tool is already built 
# and installed
#
# USAGE
#
#	should_build.sh
#
# BEHAVIOR
#
#	Checks if Node Exporter has already been built.
#
#	Returns 0 if it has not been built
#	Returns 1 if it has been built
#
#?

# {{{1 Exit on any error
set -e

# {{{1 Check if node_exporter binary exists
if which node_exporter &> /dev/null; then
	# Exists
	exit 0
else
	# Does not exist
	exit 1
fi
