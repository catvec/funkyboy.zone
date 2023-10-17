#!/usr/bin/env bash

prog_dir=$(dirname $(realpath "$0"))
set -x
PIPENV_PIPFILE="$prog_dir/setup-k8s/Pipfile" pipenv run ./setup-k8s/main.py $@