#!/bin/sh
set -e

if [ "$1" = 'relay' ]; then
    echo "=== Configure"
    om cluster create

    echo "set cluster.nodes=${HOSTNAME}"
    om cluster set --kw cluster.nodes=${HOSTNAME}

    echo "set cluster.name=${HOSTNAME}"
    om cluster set --kw cluster.name=${HOSTNAME}

    echo "set stats_collection.schedule=@0"
    om cluster set --kw stats_collection.schedule=@0

    if [ "X${SECRET}" != "X" ]; then
	    echo "set cluster.secret=${SECRET}"
	    om cluster set --kw cluster.secret=${SECRET}
    fi

    if [ "${ADDR}" != "0.0.0.0" ]; then
	    echo "set listener.addr=${ADDR}"
	    om cluster set --kw listener.addr=${ADDR}
    fi

    if [ "${PORT}" != "1214" ]; then
	    echo "set listener.port=${PORT}"
	    om cluster set --kw listener.port=${PORT}
    fi

    echo "=== Resulting configuration"
    om cluster print config

    echo "=== Start"
    exec om daemon start --foreground
fi

exec "$@"

