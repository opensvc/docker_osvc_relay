#!/bin/sh
set -e

if [ "$1" = 'relay' ]; then

    echo "Configuring OpenSVC cluster.nodes=${HOSTNAME}"
    nodemgr set --kw cluster.nodes=${HOSTNAME}

    echo "Configuring OpenSVC cluster.name=${HOSTNAME}-relay"
    nodemgr set --kw cluster.name=${HOSTNAME}-relay

    echo "Disabling statistics collection"
    nodemgr set --kw stats_collection.schedule=@0

    if [ "X${SECRET}" != "X" ]; then
	    echo "Configuring OpenSVC cluster.secret=${SECRET}"
	    nodemgr set --kw cluster.secret=${SECRET}
    fi

    if [ "${ADDR}" != "0.0.0.0" ]; then
	    echo "Configuring OpenSVC listener.addr=${ADDR}"
	    nodemgr set --kw listener.addr=${ADDR}
    fi

    if [ "${PORT}" != "1214" ]; then
	    echo "Configuring OpenSVC listener.port=${PORT}"
	    nodemgr set --kw listener.port=${PORT}
    fi

    exec /usr/bin/python /opt/opensvc/lib/osvcd.py -f
fi

exec "$@"
