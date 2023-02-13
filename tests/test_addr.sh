#!/bin/sh

. ./common.sh

testAddr() {
    local rc
    ( dexec ${cname} om cluster get --kw listener.addr >"${stdoutF}" 2>"${stderrF}" )
    rc=$?

    assertTrue "the command exited with an error" ${rc}
    [ ${rc} -eq 0 ] || showOutput

    grep -q '127.0.0.1' "${stdoutF}" >/dev/null
    assertTrue 'cluster.conf ip addr is not as expected' $?
}

testNodeLog() {
    local rc
    ( dexec ${cname} grep lsnr-raw-inet /var/log/opensvc/node.log >"${stdoutF}" 2>"${stderrF}" )
    rc=$?

    assertTrue "the command exited with an error" ${rc}
    [ ${rc} -eq 0 ] || showOutput

    grep -q 'listener started 127.0.0.1:1214' "${stdoutF}" >/dev/null
    assertTrue 'node.log ip addr is not as expected' $?
}

tearDown() {
    docker rm -f ${cname} >> /dev/null 2>&1
}

setUp() {
  cp /dev/null "${stdoutF}"
  cp /dev/null "${stderrF}"
  dcleanup
  docker run -d -it --name ${cname} --rm -e ADDR=127.0.0.1 ${image}  >> /dev/null 2>&1
  dWaitIdle ${cname}
}

# sourcing the unit test framework
# shellcheck source=/dev/null
. ${SHUNIT_PATH:-/usr/bin/shunit2}
