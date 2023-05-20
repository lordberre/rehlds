#!/bin/bash
CONTAINER=lordberre_hlds

# Force CPU affinity to CPU2
# docker run --cpuset-cpus="2" -d --restart=always -v $(pwd)/cstrike_data:/opt/steam/hlds/cstrike --name $CONTAINER -p 27031:27031/udp -p 27031:27031/tcp -p 26901:26901/udp $CONTAINER
#docker run --network=hlstatsx-community-edition_hlstats --cpuset-cpus="2" -d --restart=always --mount source=hldsdata_dev,destination=/opt/steam/hlds/cstrike --name $CONTAINER -p 27031:27031/udp -p 27031:27031/tcp -p 26901:26901/udp $CONTAINER
docker run --network=hlds_network --cpuset-cpus="3" --ip 172.99.0.4 -d --restart=always --name $CONTAINER -p 27015:27015/udp -p 27015:27015/tcp -p 26900:26900/udp $CONTAINER

# Default
# docker run -d --restart=always --name $CONTAINER -p 27031:27031/udp -p 27031:27031/tcp -p 26901:26901/udp $CONTAINER

