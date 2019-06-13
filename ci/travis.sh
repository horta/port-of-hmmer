#!/usr/bin/env bash

set -e

if [ "$TRAVIS_OS_NAME" == "linux" ]
then
  IMAGE_NAME=hortaebi/port-of-hmmer:$TARGET

  if [ "${BUILD_IMAGE+x}" = "x" ] && [ "$BUILD_IMAGE" == "true" ]
  then
    echo "Building docker image $IMAGE_NAME..."
    (cd $TARGET && docker build -t $IMAGE_NAME .)
  else
    echo "Pulling docker image $IMAGE_NAME..."
    docker pull $IMAGE_NAME
  fi
  echo "Docker image done."

  docker run -dit -v $TRAVIS_BUILD_DIR:/hostdir --name $TARGET $IMAGE_NAME
  docker inspect -f {{.State.Health.Status}} $TARGET

  until [ "`docker inspect -f {{.State.Health.Status}} $TARGET`" == "healthy" ]
  do
    sleep 30;
    echo "Waiting for docker service to finish startup..."
  done

  msg=(docker inspect -f {{.State.Health.Status}} $TARGET)
  echo "Docker service is $msg."

  docker exec -t $TARGET ssh_run "apt-get update && apt-get upgrade -y"
  docker exec -t $TARGET ssh_run "apt-get install -y python3"

  echo "Docker service startup has finished!"
fi

mkdir $HOME/bin || true

curl https://raw.githubusercontent.com/horta/port-of-hmmer/master/ci/sandbox_run \
    --output $HOME/bin/sandbox_run
chmod +x $HOME/bin/sandbox_run
