#!/usr/bin/env bash

set -e

sandbox_run_setup()
{
  mkdir $HOME/bin || true
  curl https://raw.githubusercontent.com/horta/port-of-hmmer/master/ci/sandbox_run \
      --output $HOME/bin/sandbox_run
  chmod +x $HOME/bin/sandbox_run
  hash -r
}

ppc_setup()
{
  curl http://rest.s3for.me/hmmer/debian-wheezy-powerpc.qcow2 \
    --output debian-wheezy-powerpc.qcow2

  touch nohup.out
  nohup qemu-system-ppc -nographic -vga none -L bios \
    -hda ./debian-wheezy-powerpc.qcow2 -m 512M -net user,hostfwd=tcp::22125-:22 \
    -virtfs local,path=$TRAVIS_BUILD_DIR,mount_tag=host0,security_model=passthrough,id=host0 \
    -net nic >nohup.out 2>&1 &
  
  tail -f nohup.out | tee /dev/tty | while read LOGLINE
  do
    [[ "${LOGLINE}" == *"Debian GNU/Linux 7 debian-powerpc"* ]] && pkill -P $$ tail
  done

  echo "PPC machine has started."
}

sandbox_run_setup

if [ "$TARGET" == "powerpc-unknown-linux-gnu" ]
then
  sudo apt-get install -y qemu qemu-system-ppc openssh-clients sshpass

  ppc_setup
  DIR=/hostdir
  sandbox_run "echo \"host0 $DIR 9p trans=virtio,version=9p2000.L 0 0\" >> /etc/fstab"
  sandbox_run "mkdir -p $DIR"
  sandbox_run "mount $DIR"
fi
