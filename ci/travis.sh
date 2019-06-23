#!/usr/bin/env bash

set -e

HOME_TMP=$HOME/.port-of-hmmer
HOME_BIN=$HOME/bin

echo "HOME_TMP: $HOME_TMP"
echo "HOME_BIN: $HOME_BIN"

sandbox_run_setup()
{
  echo "Setting sandbox up..."
  test -d $HOME_TMP || mkdir $HOME_TMP
  test -d $HOME_BIN || mkdir $HOME_BIN
  echo "HOME_TMP: $HOME_TMP"
  echo "HOME_BIN: $HOME_BIN"

  curl https://raw.githubusercontent.com/horta/port-of-hmmer/master/ci/sandbox_run \
      --output $HOME_BIN/sandbox_run
  chmod +x $HOME_BIN/sandbox_run

  hash -r
  echo "Sandbox setup is done."
}

ppc_setup()
{
  echo "Setting ppc up..."

  curl http://rest.s3for.me/hmmer/debian-wheezy-powerpc.qcow2.bz2 \
    --output $HOME_TMP/debian-wheezy-powerpc.qcow2.bz2
  bunzip2 -v $HOME_TMP/debian-wheezy-powerpc.qcow2.bz2
  PPC_FILE=$HOME_TMP/debian-wheezy-powerpc.qcow2

  touch $HOME_TMP/nohup.out
  VIRT=local,path=$TRAVIS_BUILD_DIR,mount_tag=host0,security_model=passthrough,id=host0
  nohup qemu-system-ppc -nographic -vga none -L bios \
    -hda $PPC_FILE -m 512M -net user,hostfwd=tcp::22125-:22 \
    -virtfs $VIRT -net nic >$HOME_TMP/nohup.out 2>&1 &

  tail -f $HOME_TMP/nohup.out | tee /dev/tty | while read LOGLINE
  do
    [[ "${LOGLINE}" == *"Debian GNU/Linux 7 debian-powerpc"* ]] && break
  done

  usr_id=$(id -u)
  grp_id=$(id -g)
  usr_name=$(id -un)

  ppc_run ()
  {
    sshpass -p "root" ssh -t -oStrictHostKeyChecking=no 127.0.0.1 -p 22125 -l root "$@"
  }
  
  ppc_run groupadd -g $grp_id $usr_name
  ppc_run useradd -u $usr_id -g $grp_id -m $usr_name
  # ppc_run pam-auth-update
  sshpass -p "root" ssh -t -oStrictHostKeyChecking=no 127.0.0.1 -p 22125 -l root "echo $usr_name:$usr_name | chpasswd"

  echo "PPC setup is done."
}

x86_64_setup()
{
  echo "Setting x86_64 up..."
  IMAGE_NAME=hortaebi/port-of-hmmer:$TARGET

  if [ "${BUILD_IMAGE+x}" = "x" ] && [ "$BUILD_IMAGE" == "true" ]
  then
    (cd $TARGET && docker build -t $IMAGE_NAME .)
  else
    docker pull $IMAGE_NAME
  fi

  docker run -dit -v $TRAVIS_BUILD_DIR:/hostdir --name $TARGET $IMAGE_NAME
  echo "x86_64 setup is done."
}

sandbox_run_setup

if [ "$TARGET" == "powerpc-unknown-linux-gnu" ]; then
  ppc_setup
elif [ "$TARGET" == "x86_64-pc-linux-gnu" ]; then
  x86_64_setup
fi
