# docker_osvc_relay
opensvc agent container preconfigured with hearbeat relay role

considering a 2 nodes (n1 & n2) opensvc cluster stretched over 2 datacenters, this container can be instanciated on a third datacenter.
once the cluster is configured to point to the heartbeat relay, a complete network cut between n1 and n2 won't end in split brain situation, because hearbeats are still being exchanged through the relay.

more informations available here https://docs.opensvc.com/latest/agent.daemon.heartbeats.html#relay


Usage :
-----
AES secret is expected to be configured at container runtime, based on environmnent variable SECRET

    docker run -e SECRET=1234567812345678 opensvc/docker_osvc_relay


Note :
----
AES secret key must be either 16, 24, or 32 bytes long. You can use the one-liner below.
 
    python -c "import uuid;print(uuid.uuid1().hex)"


By default, relay is listening on 0.0.0.0:1214. Override is possible by using variable ADDR and/or PORT.

Examples :
--------

    docker run -e SECRET=1234567812345678 opensvc/docker_osvc_relay                                     # listen on 0.0.0.0:1214
    docker run -e SECRET=1234567812345678 -e ADDR=192.168.100.1 opensvc/docker_osvc_relay               # listen on 192.168.100.1:1214
    docker run -e SECRET=1234567812345678 -e PORT=9999 opensvc/docker_osvc_relay                        # listen on 0.0.0.0:9999
    docker run -e SECRET=1234567812345678 -e ADDR=192.168.100.1 -e PORT=4321 opensvc/docker_osvc_relay  # listen on 192.168.100.1:4321
