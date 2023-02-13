#!/bin/sh

. ./common.sh

testSecret() {
    local rc
    ( dexec ${cname} om cluster get --kw cluster.secret >"${stdoutF}" 2>"${stderrF}" )
    rc=$?

    assertTrue "the command exited with an error" ${rc}
    [ ${rc} -eq 0 ] || showOutput

    grep -q '1234567812345678' "${stdoutF}" >/dev/null
    assertTrue 'Secret is not as expected' $?
}

tearDown() {
    docker rm -f ${cname} >> /dev/null 2>&1
}

setUp() {
  cp /dev/null "${stdoutF}"
  cp /dev/null "${stderrF}"
  dcleanup
  docker run -d -it --name ${cname} --rm -e SECRET=1234567812345678 ${image}  >> /dev/null 2>&1
  dWaitIdle ${cname}
}

# sourcing the unit test framework
# shellcheck source=/dev/null
. ${SHUNIT_PATH:-/usr/bin/shunit2}
