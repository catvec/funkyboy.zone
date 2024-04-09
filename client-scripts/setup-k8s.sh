#!/usr/bin/env bash

prog_dir=$(dirname $(realpath "$0"))
export PIPENV_PIPFILE="$prog_dir/Pipfile"

set -x
pipenv run python "$prog_dir/client_scripts/setup_k8s.py" $@