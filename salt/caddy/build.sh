#!/usr/bin/env bash
#?
# build.sh - Build Caddy
#
# USAGE
#
#	build.sh
#
# BEHAVIOR
#
#	Build Caddy in current working directory.
#
#?

# {{{1 Exit on any error
set -e

# {{{1 Setup a GOPATH in the current directory
echo "===== Making local GOPATH build directory"

export GOPATH=build-gopath

if ! mkdir -p "$GOPATH"; then
	echo "Error: Failed to make local GOPATH build directory: $GOPATH" >&2
	exit 1
fi

# {{{1 Download Caddy
echo "===== Downloading"

if ! go get github.com/mholt/caddy/caddy; then
	echo "Error: Failed to go get Caddy" >&2
	exit 1
fi

if ! go get github.com/caddyserver/builds; then
	echo "Error: Failed to go get Caddy builds" >&2
	exit 1
fi

# {{{1 Switch to build directory
echo "===== Switching to build directory"

if ! cd "$GOPATH/src/github.com/mholt/caddy/caddy"; then
	echo "Error: Failed to change to Caddy build directory" >&2
	exit 1
fi

# {{{1 Enable plugins
echo "===== Enabling plugins"

plugin_file="caddymain/run.go"
plugins_string=<<EOF
import _ "github.com/caddyserver/dnsproviders/digitalocean"
EOF

# {{{2 Compose new plugins file
# {{{3 Backup old plugin file
plugin_file_backup="$plugin_file.old"

if ! cp "$plugin_file" "$plugin_file_backup"; then
	echo "Error: Failed to backup Caddy plugin file" >&2
	exit 1
fi

# {{{3 Edit plugin file
# {{{4 Get start of file
inject_line_start=$(cat "$plugin_file" | sed '/package caddymain/q' | wc -l)
if [[ "$?" != "0" ]]; then
	echo "Error: Failed to get line count to package statement in plugin file" >&2
	exit 1
fi

plugin_file_begin=$(head -n "$inject_line_start" "$plugin_file")
if [[ "$?" != "0" ]]; then
	echo "Error: Failed to get beginning of plugin file" >&2
	exit 1
fi

plugin_file_end=$(tail -n $(("$inject_line_start" + 1)) "$plugin_file")
if [[ "$?" != "0" ]]; then
	echo "Error: Failed to get end of plugin file" >&2
	exit 1
fi

echo "$plugin_file_begin\n$plugins_string\n$plugin_file_end" > "$plugin_file"
if [[ "$?" != "0" ]]; then
	echo "Error: Failed to inject plugins" >&2
	exit 1
fi

# {{{1 Build
echo "===== Building"

if ! go run build.go; then
	echo "Error: Failed to build Caddy" >&2
	exit 1
fi

# {{{1 Remove plugins from plugins file
echo "===== Disabling plugins"

if ! mv "$plugin_file_backup" "$plugin_file"; then
	echo "Error: Failed to restore old plugins file" >&2
	exit 1
fi
