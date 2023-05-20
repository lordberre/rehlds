#!/bin/bash
source .env
docker run --network=hlds_network --cpuset-cpus="1" --ip 172.99.0.3 -d --restart=always --name $CONTAINER -p 27016:27016/udp -p 27016:27016/tcp -p 26902:26902/udp $CONTAINER

