#!/usr/bin/env bash

set -e

if [ "$TRAVIS_OS_NAME" == "linux" ]
then
  IMAGE_NAME=hortaebi/port-of-hmmer:$TARGET

  if [ "${BUILD_IMAGE+x}" = "x" ] && [ "$BUILD_IMAGE" == "true" ]
  then
    (cd $TARGET && docker build -t $IMAGE_NAME .)
  else
    docker pull $IMAGE_NAME
  fi

  docker run -dit -v $TRAVIS_BUILD_DIR:/hostdir --name $TARGET $IMAGE_NAME
  docker inspect -f {{.State.Health.Status}} $TARGET

  until [ "`docker inspect -f {{.State.Health.Status}} $TARGET`" == "healthy" ]
  do
    sleep 30;
    echo "Waiting for docker service to finish startup..."
  done

  docker exec -t $TARGET ssh_run "apt-get install -y python3"

  echo "Docker service startup has finished!"
fi

mkdir $HOME/bin || true

curl https://raw.githubusercontent.com/horta/port-of-hmmer/master/ci/sandbox_run \
    --output $HOME/bin/sandbox_run
chmod +x $HOME/bin/sandbox_run
