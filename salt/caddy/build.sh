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

# {{{1 Configurations
plugins=("github.com/caddyserver/dnsproviders/digitalocean")

# {{{1 Setup a GOPATH in the current directory
echo "===== Making local GOPATH build directory"

export GOPATH="$PWD/build-gopath"

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

# {{{2 Install plugins
for plugin in "${plugins[@]}"; do
	if ! go get -u "$plugin"; then
		echo "Error: Failed to go get \"$plugin\" plugin" >&2
		exit 1
	fi
done

# {{{2 Compose new plugins file
plugin_file="caddymain/run.go"

# {{{3 Backup old plugin file
plugin_file_backup="$plugin_file.old"

if ! cp "$plugin_file" "$plugin_file_backup"; then
	echo "Error: Failed to backup Caddy plugin file" >&2
	exit 1
fi

# {{{3 Edit plugin file
# {{{4 Find area to inject plugins in
inject_line_start=$(cat "$plugin_file" | sed '/package caddymain/q' | wc -l)
if [[ "$?" != "0" ]]; then
	echo "Error: Failed to get line count to package statement in plugin file" >&2
	exit 1
fi

# {{{4 Add start of file
if ! head -n "$inject_line_start" "$plugin_file_backup" > "$plugin_file"; then
	echo "Error: Failed to inject beginning of plugins file" >&2
	exit 1
fi

# {{{4 Add plugins into file
for plugin in "${plugins[@]}"; do
	if ! echo "import _ \"$plugin\"" >> "$plugin_file"; then
		echo "Error: Failed to inject \"$plugin\" plugin into plugins file" >&2
		exit 1
	fi
done

# {{{4 Add end of file
if ! tail -n +$(("$inject_line_start" + 1)) "$plugin_file_backup" >> "$plugin_file"; then
	echo "Error: Failed to inject end of plugins file" >&2
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

# {{{1 Add binary to path
echo "===== Install Caddy"
install_file="/usr/bin/caddy"

if ! mv "$GOPATH/bin/caddy" "$install_file"; then
	echo "Error: Failed to copy Caddy binary to /usr/bin" >&2
	exit 1
fi

if ! chown caddy:caddy "$install_file"; then
	echo "Error: Failed to chown Caddy binary" >&2
	exit 1
fi

if ! chmod 775 "$install_file"; then
	echo "Error: Failed to chmod Caddy binary" >&2
	exit 1
fi
