#!/usr/bin/env bash
#?
# any-prometheus-push.sh - Pushes Prometheus metrics to a specific Push Gateway
#
# USAGE
#
#	any-prometheus-push.sh OPTIONS
#
# OPTIONS
#
#	-s PUSH_SRV    Prometheus Push Gateway to send metric to
#	-j JOB         Metric job annotation
#	-m METRIC      Metric name
#	-v VALUE       Metric value
#
# BEHAVIOR
#
#	Uses a Prometheus Push Gateway server HTTP API to push a metric
#	to Prometheus.
#
#?

# {{{1 Exit on any error
set -e

# {{{1 Options
# {{{2 Get
while getopts "s:j:m:v:" opt; do
	case "$opt" in
		s)
			push_srv="$OPTARG"
			;;

		j)
			job="$OPTARG"
			;;

		m)
			metric="$OPTARG"
			;;

		v)
			value="$OPTARG"
			;;

		'?')
			echo "Error: Unknown option \"$opt\"" >&2
			exit 1
			;;
	esac
done

# {{{2 Verify
# {{{3 push_srv
if [ -z "$push_srv" ]; then
	echo "Error: 0s PUSH_SRV option required" >&2
	exit 1
fi

# {{{3 job
if [ -z "$job" ]; then
	echo "Error: -s JOB option required" >&2
	exit 1
fi

# {{{3 metric
if [ -z "$metric" ]; then
	echo "Error: -m METRIC option required" >&2
	exit 1
fi

# {{{3 value
if [ -z "$value" ]; then
	echo "Error: -v VALUE option required" >&2
	exit 1
fi

# {{{1 Push
if ! echo "$metric $value" | curl --data-binary @- "$push_srv/metrics/job/$job"; then
	echo "Error: Failed to push $metric to $push_srv for $job" >&2
	exit 1
fi
