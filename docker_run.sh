#!/bin/bash
source .env
if [[ $FOREGROUND == true ]]; then
    docker run --network=hlds_network --cpuset-cpus="0" --ip $HLDS_IP -it --restart=always --name $CONTAINER -p $HLDS_PORT:$HLDS_PORT/udp -p $HLDS_PORT:$HLDS_PORT/tcp -p $HLDS_VACPORT:$HLDS_VACPORT/udp $CONTAINER
else
    docker run --network=hlds_network --cpuset-cpus="0" --ip $HLDS_IP -d --restart=always --name $CONTAINER -p $HLDS_PORT:$HLDS_PORT/udp -p $HLDS_PORT:$HLDS_PORT/tcp -p $HLDS_VACPORT:$HLDS_VACPORT/udp $CONTAINER
fi
