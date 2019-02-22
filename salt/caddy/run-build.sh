#!/usr/bin/env bash
#?
# run-build.sh - Run build.sh
#
# USAGE
#
#	run-build.sh
#
# BEHAVIOR
#
#	Runs build.sh with the correct options.
#
#?

{{ pillar.caddy.build.build_script }} \
	-r {{ pillar.caddy.build.repo }} \
	-g {{ pillar.caddy.build.gopath }} \
	-f {{ pillar.caddy.build.plugins_file }} \
	{% for plugin in pillar['caddy']['build']['plugins'] %} -p {{ plugin }} {% endfor %} \
	-h {{ pillar.caddy.build.plugins_history_file }} \
	-o {{ pillar.caddy.files.user }}:{{ pillar.caddy.files.group }}
