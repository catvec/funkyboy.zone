#!/usr/bin/env bash
#?
# build.sh - Builds Caddy
#
# USAGE
#
#    build.sh
#
# BEHAVIOR
#
#    Automates builds instructions here: https://github.com/caddyserver/caddy#build
#
#    Commicates state back to Salt using protocol: https://docs.saltstack.com/en/latest/ref/states/all/salt.states.cmd.html#using-the-stateful-argument
#
#    Outputs file: pillar.caddy.install_file
#
#    This script uses Jinja templating.
#
#?

set -e

cd "{{ pillar.caddy.build_dir }}"

if [ ! -f ./go.mod ]; then
    go mod init caddy
fi

# {% for plugin in pillar['caddy']['plugins'] %}
go get "{{ plugin.pkg }}@{{ plugin.version }}"
# {% endfor %}
go build
mv caddy "{{ pillar.caddy.install_file }}"
