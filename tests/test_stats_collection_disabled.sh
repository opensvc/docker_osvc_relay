#!/bin/sh

. ./common.sh

testStatsDisabled() {
    local rc
    ( dexec ${cname} om cluster get --kw stats_collection.schedule >"${stdoutF}" 2>"${stderrF}" )
    rc=$?

    assertTrue "the command exited with an error" ${rc}
    [ ${rc} -eq 0 ] || showOutput

    grep -q '@0' "${stdoutF}" >/dev/null
    assertTrue 'stats collection is not as expected' $?
}

tearDown() {
    docker rm -f ${cname} >> /dev/null 2>&1
}

setUp() {
  cp /dev/null "${stdoutF}"
  cp /dev/null "${stderrF}"
  dcleanup
  docker run -d -it --name ${cname} --rm ${image}  >> /dev/null 2>&1
  dWaitIdle ${cname}
}

# sourcing the unit test framework
# shellcheck source=/dev/null
. ${SHUNIT_PATH:-/usr/bin/shunit2}
