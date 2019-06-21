#!/usr/bin/env bash

set -e

sandbox_run_setup()
{
  test -d $HOME/bin || mkdir $HOME/bin
  curl https://raw.githubusercontent.com/horta/port-of-hmmer/master/ci/sandbox_run \
      --output $HOME/bin/sandbox_run
  chmod +x $HOME/bin/sandbox_run
  hash -r
}

ppc_setup()
{
  curl http://rest.s3for.me/hmmer/debian-wheezy-powerpc.qcow2.bz2 \
    --output debian-wheezy-powerpc.qcow2.bz2
  bunzip2 debian-wheezy-powerpc.qcow2.bz2

  touch nohup.out
  VIRT=local,path=$TRAVIS_BUILD_DIR,mount_tag=host0,security_model=passthrough,id=host0
  # nohup
  qemu-system-ppc -nographic -vga none -L bios \
    -hda ./debian-wheezy-powerpc.qcow2 -m 512M -net user,hostfwd=tcp::22125-:22 \
    -virtfs $VIRT -net nic
  # >nohup.out 2>&1 &
  
  tail -f nohup.out | tee /dev/tty | while read LOGLINE
  do
    [[ "${LOGLINE}" == *"Debian GNU/Linux 7 debian-powerpc"* ]] && pkill -P $$ tail
  done

  echo "PPC machine has started."
}

sandbox_run_setup

if [ "$TARGET" == "powerpc-unknown-linux-gnu" ]
then
  ppc_setup
  DIR=/hostdir
  sandbox_run "mount $DIR"
elif [ "$TARGET" == "x86_64-pc-linux-gnu" ]
then
  IMAGE_NAME=hortaebi/port-of-hmmer:$TARGET
  if [ "${BUILD_IMAGE+x}" = "x" ] && [ "$BUILD_IMAGE" == "true" ]
  then
    (cd $TARGET && docker build -t $IMAGE_NAME .)
  else
    docker pull $IMAGE_NAME
  fi

  DIR=/hostdir
  docker run -dit -v $TRAVIS_BUILD_DIR:$DIR --name $TARGET $IMAGE_NAME
fi
