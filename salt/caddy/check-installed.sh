#!/usr/bin/env bash
#?
# check-installed.sh - Check if the latest version of Caddy is installed
#
# USAGE
#
# 	check-installed.sh BUILD_DIR
#
# ARGUMENTS
#
#	BUILD_DIR    Directory where Caddy is built
#
# BEHAVIOR
#
# 	Determines if Caddy is installed and if the latest version 
#	is installed.
#
#	If it is not installed, or the latest version is not installed the
#	script exits with a non-zero exit code
#
#?

# {{{1 Exit on any error
set -e

# {{{1 Arguments
if [ -z "$1" ]; then
	echo "Error: BUILD_DIR argument is required" >&2
	exit 1
fi
build_dir="$1"

# {{{1 Check if installed at all
if ! which caddy &> /dev/null; then
	echo "Error: Caddy not installed" >&2
	exit 100
fi

# {{{1 Check if latest version is installed
# {{{2 Get latest tag from GitHub releases API
latest_tag=$(curl -L api.github.com/repos/mholt/caddy/releases/latest | grep "tag_name" | sed 's/"tag_name": "//g' | sed 's/",//g' | awk '{ print $1 }')
if [[ "$?" != "0" ]]; then
	echo "Error: Failed to get latest GitHub release tag" >&2
	exit 1
fi

# {{{2 Get latest tag of cloned down version on server
if ! cd "$build_dir/build-gopath/src/github.com/mholt/caddy"; then
	echo "Error: Failed to cd into Caddy repository" >&2
	exit 1
fi

current_tag=$(git describe --abbrev=0 --tags)
if [[ "$?" != "0" ]]; then
	echo "Error: Failed to get local Git tag" >&2
	exit 1
fi

# {{{1 Compare version
if [[ "$latest_tag" != "$current_tag" ]]; then
	echo "Error: Most recent version of Caddy not installed, latest: $latest_tag, current: $current_tag" >&2
	exit 100
fi

echo "Installed"
