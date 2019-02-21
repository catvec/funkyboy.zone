#!/usr/bin/env bash
#?
# run-restore.sh - Runs restore script
#
# USAGE
#
#	run-restore.sh
#
# BEHAVIOR
#
#	Runs the restore script will all the correct arguments.
#
#?

{{ pillar.backup.restore_script }} \
	-s {{ pillar.backup.space }} \
	-c {{ pillar.backup.s3cmd_config }}
