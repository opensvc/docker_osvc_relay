set -a

export image="opensvc/relay:3.0.0"
export cname="osvc_test_container"
export tmpdir=/tmp
export stdoutF="${tmpdir}/stdout"
export stderrF="${tmpdir}/stderr"


dexec() {
    c=$1
    shift
    docker exec -it ${c} "$@"
}

dGetIp() {
    c=$1
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${c}
}

dGetHostsPath() {
    c=$1
    docker inspect -f '{{.HostsPath}}' ${c}
}

dcleanup() {
    for c in $(docker ps -a | grep ${cname} | awk '{print $1}')
    do
	docker rm -f ${c} >> /dev/null
    done
}

dWaitIdle() {
    c=$1
    # printf "waiting: docker exec $c /usr/bin/om daemon running ."
    local rc
    while true
    do
	    #dexec ${c} grep -sqE ".*sub.*listener.*started" /var/log/opensvc/node.log 2>/dev/null
	    #docker exec $c /usr/bin/om daemon running && echo && break
	    docker exec $c /usr/bin/om daemon running && return 0
	    #printf .
	    sleep 1
    done
    return 1
}

showOutput() {
  # shellcheck disable=SC2166
  if [ -n "${stdoutF}" -a -s "${stdoutF}" ]; then
    echo '>>> STDOUT' >&2
    cat "${stdoutF}" >&2
    echo '<<< STDOUT' >&2
  fi
  # shellcheck disable=SC2166
  if [ -n "${stderrF}" -a -s "${stderrF}" ]; then
    echo '>>> STDERR' >&2
    cat "${stderrF}" >&2
    echo '<<< STDERR' >&2
  fi
}
