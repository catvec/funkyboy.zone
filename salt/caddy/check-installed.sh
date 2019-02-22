#!/usr/bin/env bash
#?
# check-installed.sh - Check if the latest version of Caddy is installed
#
# USAGE
#
# 	check-installed.sh OPTIONS
#
# OPTIONS
#
#	-d BUILD_DIR       Directory of Caddy repository
#	-f PLUGINS_FILE    File in which to place plugins, should be 
#	                   relative to BUILD_DIR
#	-h HISTORY_FILE    File which will contain the names of the plugins
#	                   injected during the build process
#	-p PLUGIN          (Optional) Plugin to check is installed, can be 
#	                   specified multiple times
#
# BEHAVIOR
#
# 	Determines if Caddy is installed, if the latest version 
#	is installed, and if all the required plugins are installed.
#
#	If any of the above conditions are not met the script exits with a 
#	non-zero exit code.
#
#?

# {{{1 Exit on any error
set -e

# {{{1 Configuration
plugins=()

# {{{1 Arugments
# {{{2 Get
while getopts "d:f:h:p:" opt; do
	case "$opt" in 
		d)
			build_dir="$OPTARG"
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

		'?')
			echo "Error: Unknown option \"$opt\"" >&2
			exit 1
			;;
	esac
done

# {{{2 Check
# {{{3 Build directory
if [ -z "$build_dir" ]; then
	echo "Error: -d BUILD_DIR option required" >&2
	exit 1
fi

# {{{3 Plugins file
if [ -z "$plugins_file" ]; then
	echo "Error: -f PLUGINS_FILE option is required" >&2
	exit 1
fi

# {{{3 Plugins history file
if [ -z "$plugins_history_file" ]; then
	echo "Error: -h HISTORY_FILE option is required" >&2
	exit 1
fi

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
if ! cd "$build_dir"; then
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

# {{{1 Check for plugins
tmp_plugins_history_f="/tmp/caddy-check-plugins-history"
abc_plugins_history_f="/tmp/caddy-abc-plugins-history"

function cleanup() {
	rm "$tmp_plugins_history_f" || true
	rm "$abc_plugins_history_f" || true
}

# {{{2 Create temporary file with all plugin names
for plugin in "${plugins[@]}"; do
	if ! echo "$plugin" >> "$tmp_plugins_history_f"; then
		echo "Error: Failed to add \"$plugin\" plugin to temporary plugins history file: $tmp_plugins_history_f" >&2
		cleanup
		exit 1
	fi
done

# {{{2 Alphabetize both files
# {{{3 Plugins history file in build directory
if ! {cat "$plugins_history_file" | sort -d | tee "$abc_plugins_history_f"} ; then
	echo "Error: Failed to alphabetize plugins history file in build directory: $plugins_history_file" >&2
	cleanup
	exit 1
fi

# {{{3 Temp history file
if ! cat "$tmp_plugins_history_f" | sort -d | tee "$tmp_plugins_history_f"; then
	echo "Error: Failed to alphabetize temporary plugins history file: $tmp_plugins_history_f" >&2
	cleanup
	exit 1
fi

# {{{2 Compare
if ! diff "$tmp_plugins_history_f" "$abc_plugins_history_f"; then
	echo "Plugins are not the same"
	cleanup
	exit 100
fi

cleanup
echo "Installed and up to date"
