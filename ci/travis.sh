#!/usr/bin/env bash

set -e

IMAGE_NAME=hortaebi/port-of-hmmer:$TARGET
docker pull $IMAGE_NAME
docker run -dit -v $TRAVIS_BUILD_DIR:/hostdir --name $TARGET $IMAGE_NAME
docker inspect -f {{.State.Health.Status}} $TARGET

until [ "`docker inspect -f {{.State.Health.Status}} $TARGET`" == "healthy" ]
do
  sleep 30;
  echo "Waiting for docker service to finish startup..."
done

echo "Docker service startup has finished!"
