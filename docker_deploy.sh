#!/bin/bash
source .env
VERSION=$(git log -1 --pretty=%h)

# Add current server data and build/update
# docker network create --subnet=172.99.0.0/16 hlds_network
docker cp $CONTAINER:/opt/steam/hlds/cstrike cstrike_data
docker build --build-arg VERSION="$VERSION" \
     --build-arg PORT="$HLDS_PORT" \
     --build-arg VAC_PORT="$HLDS_VACPORT" \
     --rm -t $IMAGE . && \
docker stop $CONTAINER && docker rm $CONTAINER

# Clean up and daemonize container
rm -rf cstrike_data
docker volume prune -f
docker image prune -f
# docker system prune -f
./docker_run.sh
