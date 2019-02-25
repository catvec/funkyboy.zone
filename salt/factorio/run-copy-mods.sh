#!/usr/bin/env bash
#?
# run-mount-mods-fs.sh - Run mount-mods-fs.sh
#
# USAGE
#
#	run-mount-mods-fs.sh
#
# BEHAVIOR
#
#	Runs mount-mods-fs.sh with correct options.
#
#?

{{ pillar.factorio.copy_mods_script }} \
	-d {{ pillar.factorio.mods_directory }} \
	-s {{ pillar.factorio.mods_space.name }} \
	-r {{ pillar.factorio.factorio_service.name }}
