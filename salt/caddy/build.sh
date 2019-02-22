#!/usr/bin/env bash
#?
# build.sh - Build Caddy
#
# USAGE
#
#	build.sh OPTIONS
#
# OPTIONS
#
#	-r CADDY_REPO      Caddy GitHub repo
#	-g GOPATH          Directory to place temporary build GOPATH
#	-f PLUGINS_FILE    File in which to place plugins, should be 
#	                   relative to CADDY_REPO root
#	-p PLUGIN          (Optional) Plugin to include in Caddy build, can be
#	                   specified multiple times
#	-h HISTORY_FILE    File which will contain the names of the plugins
#	                   injected during the build process
#	-o OWNER           User and group who should own caddy binary, 
#	                   separated by a colon in Chown format
#
# BEHAVIOR
#
#	Build Caddy in current working directory.
#
#?

# {{{1 Exit on any error
set -e

# {{{1 Configuration
plugins=()

# {{{1 Arguments
# {{{2 Get
while getopts "r:g:f:p:h:o:" opt; do
	case "$opt" in
		r)
			caddy_gh="$OPTARG"
			;;

		g)
			export GOPATH="$OPTARG"
			;;

		f)
			plugins_file="$OPTARG"
			;;

		p)
			plugins+=("$OPTARG")
			;;

		h)
			plugins_history_file="$OPTARG"
			;;

		o)
			caddy_owner="$OPTARG"
			;;

		'?')
			echo "Error: Unknown option \"$opt\"" >&2
			exit 1
			;;
	esac
done

# {{{2 Validate
# {{{3 caddy_gh
if [ -z "$caddy_gh" ]; then
	echo "Error: -r CADDY_REPO option required" >&2
	exit 1
fi

# {{{3 GOPATH
if [ -z "$GOPATH" ]; then
	echo "Error: -g GOPATH option required" >&2
	exit 1
fi

# {{{3 Plugins file
if [ -z "$plugins_file" ]; then
	echo "Error: -f PLUGINS_FILE option required" >&2
	exit 1
fi

# {{{3 Plugins history file
# {{{4 Given
if [ -z "$plugins_history_file" ]; then
	echo "Error: -h HISTORY_FILE option required" >&2
	exit 1
fi

# {{{4 Delete old history file if exists
if [ -f "$plugins_history_file" ]; then
	if ! rm "$plugins_history_file"; then
		echo "Error: Failed to delete old plugins history file: $plugins_history_file" >&2
		exit 1
	fi
fi

# {{{3 Caddy owner
# {{{4 Exists
if [ -z "$caddy_owner" ]; then
	echo "Error: -o OWNER option required" >&2
	exit 1
fi

# {{{4 Correct format
if [[ ! "$caddy_owner" =~ ^.*:.*$ ]]; then
	echo "Error: -o OWNER argument must be in format USER:GROUP" >&2
	exit 1
fi

# {{{1 Setup a GOPATH in the current directory
echo "===== Making local GOPATH build directory ($GOPATH)"

if ! mkdir -p "$GOPATH"; then
	echo "Error: Failed to make local GOPATH build directory: $GOPATH" >&2
	exit 1
fi

# {{{1 Download Caddy
echo "===== Downloading"

if ! go get "$caddy_gh"; then
	echo "Error: Failed to go get Caddy" >&2
	exit 1
fi

if ! go get github.com/caddyserver/builds; then
	echo "Error: Failed to go get Caddy builds" >&2
	exit 1
fi

# {{{1 Switch to build directory
echo "===== Switching to build directory"

if ! cd "$GOPATH/src/$caddy_gh"; then
	echo "Error: Failed to change to Caddy build directory" >&2
	exit 1
fi

# {{{1 Enable plugins
echo "===== Enabling plugins"

for plugin in "${plugins[@]}"; do
	if ! go get -u "$plugin"; then
		echo "Error: Failed to go get \"$plugin\" plugin" >&2
		exit 1
	fi
done

# {{{2 Compose new plugins file
# {{{3 Backup old plugin file
plugins_file_backup="$plugins_file.old"

if ! cp "$plugins_file" "$plugins_file_backup"; then
	echo "Error: Failed to backup Caddy plugins file" >&2
	exit 1
fi

# {{{3 Edit plugin file
# {{{4 Find area to inject plugins in
# {{{5 Check the marker we are looking for exists in this version of the source
inject_line_marker="package caddymain"
if ! cat "$plugins_file" | grep "$inject_line_marker" &> /dev/null; then
	echo "Error: Failed to find inject marker, it is likely the source code has changed" >&2
	exit 1
fi

# {{{5 Find line number of marker for later use
inject_line_start=$(cat "$plugins_file" | sed "/$inject_line_marker/q" | wc -l)
if [[ "$?" != "0" ]]; then
	echo "Error: Failed to get line count to package statement in plugins file" >&2
	exit 1
fi

# {{{4 Add start of file
if ! head -n "$inject_line_start" "$plugins_file_backup" > "$plugins_file"; then
	echo "Error: Failed to inject beginning of plugins file" >&2
	exit 1
fi

# {{{4 Add plugins into file
for plugin in "${plugins[@]}"; do
	# {{{4 Add to history file
	if ! echo "$plugin" >> "$plugins_history_file"; then
		echo "Error: Failed to record plugin in plugins history file, plugin: $plugin, history file: $plugins_history_file"
		exit 1
	fi

	# {{{4 Inject
	if ! echo "import _ \"$plugin\"" >> "$plugins_file"; then
		echo "Error: Failed to inject \"$plugin\" plugin into plugins file" >&2
		exit 1
	fi
done

# {{{4 Add end of file
if ! tail -n +$(("$inject_line_start" + 1)) "$plugins_file_backup" >> "$plugins_file"; then
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

if ! mv "$plugins_file_backup" "$plugins_file"; then
	echo "Error: Failed to restore old plugins file" >&2
	exit 1
fi

# {{{1 Add binary to path
echo "===== Install Caddy"
install_file="/usr/bin/caddy"

# {{{2 Copy binary
if ! mv caddy "$install_file"; then
	echo "Error: Failed to copy Caddy binary to /usr/bin" >&2
	exit 1
fi

# {{{2 Make owned by caddy user & group
if ! chown "$caddy_owner" "$install_file"; then
	echo "Error: Failed to chown Caddy binary" >&2
	exit 1
fi

if ! chmod 775 "$install_file"; then
	echo "Error: Failed to chmod Caddy binary" >&2
	exit 1
fi

# {{{2 Give permissions to bind network ports
if ! setcap CAP_NET_BIND_SERVICE=+eip "$install_file"; then
	echo "Error: Failed to give Caddy binary permission to bind low numbered ports" >&2
	exit 1
fi
