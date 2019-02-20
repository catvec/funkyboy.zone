#!/usr/bin/env bash
# cron-run.sh - Run backup.sh
{{ pillar.backup.script }} -s {{ pillar.backup.space }} -3 {{ pillar.backup.s3cmd_config }} -f {{ pillar.backup.success_status_file }} 2>&1 | vlogger -t {{ pillar.backup.log_tag }}
