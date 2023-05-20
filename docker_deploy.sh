#!/bin/bash
VERSION=$(git log -1 --pretty=%h)
CONTAINER=lordberre_hlds
IMAGE=lordberre_hlds

# Add current server data and build/update
# docker network create --subnet=172.99.0.0/16 hlds_network
docker cp $CONTAINER:/opt/steam/hlds/cstrike cstrike_data
docker build --build-arg VERSION="$VERSION" --rm -t $IMAGE . && \
docker stop $CONTAINER && docker rm $CONTAINER

# Clean up and daemonize container
rm -rf cstrike_data
docker volume prune -f
docker image prune -f
# docker system prune -f
./docker_run.sh
