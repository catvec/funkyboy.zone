#!/usr/bin/env bash
#?
# run-check-installed.sh - Run check-installed.sh
#
# USAGE
#
#	run-check-installed.sh
#
# BEHAVIOR
#
#	Runs check-installed.sh with the correct options.
#
#?

exec {{ pillar.caddy.build.check_script }} \
	-d {{ pillar.caddy.build.gopath }}/src/{{ pillar.caddy.build.repo }} \
	-f {{ pillar.caddy.build.plugins_file }} \
	-h {{ pillar.caddy.build.plugins_history_file }} \
	-n {{ pillar.caddy.build.nobuild_file }} \
	{% for plugin in pillar['caddy']['build']['plugins'] %} -p {{ plugin }} {% endfor %}
