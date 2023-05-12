#!/bin/sh

# Force CPU affinity to CPU3
docker run --cpuset-cpus="3" -d --restart=always --name lordberre_hlds -p 27015:27015/udp -p 27015:27015/tcp -p 26900:26900/udp lordberre_hlds

# Default
# docker run -d --restart=always --name lordberre_hlds -p 27015:27015/udp -p 27015:27015/tcp -p 26900:26900/udp lordberre_hlds

