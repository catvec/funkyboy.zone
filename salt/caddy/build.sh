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
#    Communicates state back to Salt using protocol: https://docs.saltstack.com/en/latest/ref/states/all/salt.states.cmd.html#using-the-stateful-argument
#
#    Outputs file: pillar.caddy.install_file
#
#    This script uses Jinja templating.
#
#?

set -e

cd "{{ pillar.caddy.build_dir }}"

# Initialize go module
if [ ! -f ./go.mod ]; then
    go mod init caddy
fi

# h2non/gock hack / fix
# (build fails saying it cannot find a revision for h2non/gock)
# fix: https://github.com/caddyserver/caddy/issues/2598#issuecomment-489975674
h2non_gock_hack="replace github.com/h2non/gock => gopkg.in/h2non/gock.v1 v1.0.14"
if ! grep -w "$h2non_gock_hack" ./go.mod &> /dev/null; then
    echo "$h2non_gock_hack" >> ./go.mod
fi

go build
mv caddy "{{ pillar.caddy.install_file }}"

setcap CAP_NET_BIND_SERVICE=+eip "{{ pillar.caddy.install_file }}"
