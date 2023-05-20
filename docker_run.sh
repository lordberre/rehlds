#!/bin/bash
source .env
docker run --network=hlds_network --cpuset-cpus="0" --ip 172.99.0.5 -d --restart=always --name $CONTAINER -p 27017:27017/udp -p 27017:27017/tcp -p 26903:26903/udp $CONTAINER

