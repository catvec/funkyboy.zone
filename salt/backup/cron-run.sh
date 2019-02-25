#!/usr/bin/env bash
#?
# cron-run.sh - Run backup.sh
# 
# USAGE
#
#	cron-run.sh OPTIONS...
#
# OPTIONS
#
#	OPTIONS...    Any options provided will be passed to the script
#
#?

# Run
{{ pillar.backup.script }} \
	-s {{ pillar.backup.space }} \
	-p {{ pillar.pushgateway.host }} \
	-m {{ pillar.backup.success_prometheus_metric }} \
	{% for f in pillar['backup']['backup_targets'] %} -b {{ f }} {% endfor %} \
	{% for f in pillar['backup']['backup_exclude'] %} -e "{{ f }}" {% endfor %} \
	$@ \
2>&1 | vlogger -t {{ pillar.backup.log_tag }}

# Push metric
if [[ "$?" == "0" ]]; then
	metric_value="1"
else
	metric_value="0"
fi

if ! prometheus-push \
	-j {{ pillar.backup.prometheus_job }} \
	-m {{ pillar.backup.success_prometheus_metric }} \
	-v "$metric_value"; then

	echo "Error: Failed to push prometheus metric" | vlogger -t {{ pillar.backup.log_tag }}
	exit 1
fi
