#!/bin/sh

. ./common.sh

testClusterNodes() {
    local rc
    ( dexec ${cname} om cluster get --kw cluster.nodes >"${stdoutF}" 2>"${stderrF}" )
    rc=$?

    assertTrue "the command exited with an error" ${rc}
    [ ${rc} -eq 0 ] || showOutput

    grep -q 'pulsar' "${stdoutF}" >/dev/null
    assertTrue 'cluster.nodes is not as expected' $?
}

testClusterName() {
    local rc
    ( dexec ${cname} om cluster get --kw cluster.name >"${stdoutF}" 2>"${stderrF}" )
    rc=$?

    assertTrue "the command exited with an error" ${rc}
    [ ${rc} -eq 0 ] || showOutput

    grep -q 'pulsar' "${stdoutF}" >/dev/null
    assertTrue 'cluster.name is not as expected' $?
}

testHostName() {
    local rc
    ( dexec ${cname} hostname >"${stdoutF}" 2>"${stderrF}" )
    rc=$?

    assertTrue "the command exited with an error" ${rc}
    [ ${rc} -eq 0 ] || showOutput

    grep -q 'pulsar' "${stdoutF}" >/dev/null
    assertTrue 'hostname is not as expected' $?
}

tearDown() {
    docker rm -f ${cname} >> /dev/null 2>&1
}

setUp() {
  cp /dev/null "${stdoutF}"
  cp /dev/null "${stderrF}"
  dcleanup
  docker run -d -it --name ${cname} --rm --hostname=pulsar ${image}  >> /dev/null 2>&1
  dWaitIdle ${cname}
}

# sourcing the unit test framework
# shellcheck source=/dev/null
. ${SHUNIT_PATH:-/usr/bin/shunit2}
