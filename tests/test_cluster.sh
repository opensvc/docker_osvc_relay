#!/bin/sh

. ./common.sh

count=3

testClusterJoin() {
    local rc members

    ( docker exec ${cname}-n1 om daemon auth --role join --out token >"${stdoutF}" 2>"${stderrF}" )
    rc=$?

    assertTrue "the token creation command exited with an error" ${rc}
    [ ${rc} -eq 0 ] || showOutput

    tk=$(cat ${stdoutF})
    for i in $(seq 2 $count)
    do
	    #echo "${cname}-n$i joining ${cname}-n1"
	    ( docker exec ${cname}-n$i /usr/bin/om daemon join --node n1 --token $tk >"${stdoutF}" 2>"${stderrF}" )
	    rc=$?
	    assertTrue "the ${cname}-n$i join command exited with an error" ${rc}
	    [ ${rc} -eq 0 ] || showOutput
    done

    ( docker exec ${cname}-n1 om cluster get --kw cluster.nodes >"${stdoutF}" 2>"${stderrF}" )
    rc=$?

    assertTrue "the nodes query command command exited with an error" ${rc}
    [ ${rc} -eq 0 ] || showOutput

    members=$(wc -w ${stdoutF} | awk '{print $1}')
    assertEquals "${members} cluster members instead of ${count} expected" ${count} ${members}
    sleep 5
}

testClusterUnfreeze() {
    local rc
    ( docker exec -it ${cname}-n1 /bin/sh -c '/usr/bin/om node unfreeze --wait --debug --time 5s' >"${stdoutF}" 2>"${stderrF}")
    rc=$?

    assertTrue "the unfreeze command exited with an error" ${rc}
    [ ${rc} -eq 0 ] || showOutput

    for i in $(seq 2 $count)
    do
        docker exec ${cname}-n${i} test -f /var/lib/opensvc/node/frozen
        rc=$?
        assertFalse "node n${i} is still frozen" ${rc}
    done
}

testConfigureRelay() {
    # [hb#4relay]
    # relay = dev2n2
    # username = relay
    # password = system/sec/relay
    # interval = 4
    # timeout = 10
    # type = relay
    local rc
    
    docker exec ${cname}-n1 om system/sec/relay create >> /dev/null 2>&1
    docker exec ${cname}-n1 om system/sec/relay add --key password --value foo >> /dev/null 2>&1
    docker exec ${cname}-n1 om cluster set --kw hb#2.type=relay --kw hb#2.relay=relay --kw hb#2.timeout=2s --kw hb#2.interval=4 --kw hb#2.username=relay --kw hb#2.password=system/sec/relay >> /dev/null 2>&1
    rc=$?

    assertTrue "the command exited with an error" ${rc}
    [ ${rc} -eq 0 ] || showOutput

    for i in $(seq 2 $count)
    do
	for transmitter in rx tx
	do
	    for try in $(seq 10)
	    do
		sleep 1
                docker exec ${cname}-n1 grep -qE "event hb_beating for n${i} from hb#2.${transmitter}" /var/log/opensvc/node.log
                rc=$?
		[ ${rc} -eq 0 ] && break
            done
            assertTrue "n${i} hb#2.${transmitter} is still down" ${rc}
        done
    done

    docker exec -it ${cname}-n1 /bin/sh -c 'om daemon status --format flat_json --color no' >"${stdoutF}" 2>"${stderrF}"
    rc=$?

    assertTrue "the command om daemon status --format flat_json exited with an error" ${rc}
    [ ${rc} -eq 0 ] || showOutput

    for instance in $(grep 'hb#2' ${stdoutF} | awk -F'.' '{print $4}')
    do
	nbhb=0
	nbhb=$(grep -F ".sub.hb.${instance}.peers" /tmp/stdout | grep beating | grep true | wc -l)
	assertEquals "${nbhb} peer cluster hb up instead of $((${count}-1)) expected" $((${count}-1)) ${nbhb}
    done
}


oneTimeTearDown() {
  dcleanup
}

oneTimeSetUp() {
  cp /dev/null "${stdoutF}"
  cp /dev/null "${stderrF}"
  dcleanup
  for i in $(seq $count)
  do
      n=n$i
      docker run -d -it --name ${cname}-$n --hostname=$n ${image} /bin/sh >> /dev/null 2>&1
      docker exec ${cname}-$n /bin/sh -c 'nohup /usr/bin/om daemon restart > ./dev/null 2>&1 </dev/null &'
  done
  dWaitIdle ${cname}-n1
  docker exec ${cname}-n1 om cluster set --kw hb#1.type=unicast

  for i in $(seq $count)
  do
     dWaitIdle ${cname}-n$i
  done

  # setup relay
  docker run -d -it --name ${cname} ${image} /bin/sh >> /dev/null 2>&1
  docker exec ${cname} /usr/bin/om daemon restart
  dWaitIdle ${cname}
  docker exec ${cname} om system/usr/relay create >> /dev/null 2>&1
  docker exec ${cname} om system/usr/relay set --kw grant=relay >> /dev/null 2>&1
  docker exec ${cname} om system/usr/relay add --key password --value foo >> /dev/null 2>&1

  ipr=$(dGetIp ${cname})
  hostsr=$(dGetHostsPath ${cname})

  for i in $(seq $count)
  do
     n=n$i
     ipn=$(dGetIp ${cname}-$n)
     for j in $(seq $count)
     do
         hostsn=$(dGetHostsPath ${cname}-n$j)
         echo "${ipn} $n" >> ${hostsn}
	 grep -q relay ${hostsn} || {
	     echo "${ipr} relay" >> ${hostsn}
	 }
     done
  done

}

# sourcing the unit test framework
# shellcheck source=/dev/null
. ${SHUNIT_PATH:-/usr/bin/shunit2}
