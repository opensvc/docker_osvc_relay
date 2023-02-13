#!/bin/sh

. ./common.sh

testPort() {
    local rc
    ( dexec ${cname} om cluster get --kw listener.port >"${stdoutF}" 2>"${stderrF}" )
    rc=$?

    assertTrue "the command exited with an error" ${rc}
    [ ${rc} -eq 0 ] || showOutput

    grep -q '5432' "${stdoutF}" >/dev/null
    assertTrue 'Listener port is not as expected' $?
}

tearDown() {
    docker rm -f ${cname} >> /dev/null 2>&1
}

setUp() {
  cp /dev/null "${stdoutF}"
  cp /dev/null "${stderrF}"
  dcleanup
  docker run -d -it --name ${cname} --rm -e PORT=5432 ${image}  >> /dev/null 2>&1
  dWaitIdle ${cname}
}

# sourcing the unit test framework
# shellcheck source=/dev/null
. ${SHUNIT_PATH:-/usr/bin/shunit2}
