#!/usr/bin/env bash

set -e

HOME_TMP=$HOME/.port-of-hmmer
HOME_BIN=$HOME/bin

echo "HOME_TMP: $HOME_TMP"
echo "HOME_BIN: $HOME_BIN"

sandbox_run_setup()
{
  echo "Setting sandbox up..."
  set -x
  test -d $HOME_TMP || mkdir $HOME_TMP
  test -d $HOME_BIN || mkdir $HOME_BIN

  curl https://raw.githubusercontent.com/horta/port-of-hmmer/master/ci/sandbox_run \
      --output $HOME_BIN/sandbox_run
  chmod +x $HOME_BIN/sandbox_run

  hash -r
  set +x
  echo "Sandbox setup is done."
}

ppc_setup()
{
  echo "Setting ppc up..."
  set -x

  curl http://rest.s3for.me/hmmer/debian-wheezy-powerpc.qcow2.bz2 \
    --output $HOME_TMP/debian-wheezy-powerpc.qcow2.bz2
  bunzip2 $HOME_TMP/debian-wheezy-powerpc.qcow2.bz2

  touch $HOME_TMP/nohup.out
  VIRT=local,path=$TRAVIS_BUILD_DIR,mount_tag=host0,security_model=passthrough,id=host0
  nohup qemu-system-ppc -nographic -vga none -L bios \
    -hda ./debian-wheezy-powerpc.qcow2 -m 512M -net user,hostfwd=tcp::22125-:22 \
    -virtfs $VIRT -net nic >$HOME_TMP/nohup.out 2>&1 &

  ( tail -f -n0 $HOME_TMP/nohup.out & ) | grep -q "Debian GNU/Linux 7 debian-powerpc"

  set +x
  echo "PPC setup is done."
}

x86_64_setup()
{
  echo "Setting x86_64 up..."
  set -x
  IMAGE_NAME=hortaebi/port-of-hmmer:$TARGET

  if [ "${BUILD_IMAGE+x}" = "x" ] && [ "$BUILD_IMAGE" == "true" ]
  then
    (cd $TARGET && docker build -t $IMAGE_NAME .)
  else
    docker pull $IMAGE_NAME
  fi

  docker run -dit -v $TRAVIS_BUILD_DIR:/hostdir --name $TARGET $IMAGE_NAME
  set +x
  echo "x86_64 setup is done."
}

sandbox_run_setup

if [ "$TARGET" == "powerpc-unknown-linux-gnu" ]; then
  ppc_setup
elif [ "$TARGET" == "x86_64-pc-linux-gnu" ]; then
  x86_64_setup
fi
