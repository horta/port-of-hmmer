#!/usr/bin/env bash

DIR=/hostdir

touch nohup.out
nohup /usr/bin/qemu-system-ppc -nographic -vga none -L bios \
    -hda ./debian-wheezy-powerpc.qcow2 -m 512M -net user,hostfwd=tcp::22125-:22 \
    -virtfs local,path=$DIR,mount_tag=host0,security_model=passthrough,id=host0 \
    -net nic >nohup.out 2>&1 &

tail -f nohup.out | tee /dev/tty | while read LOGLINE
do
    [[ "${LOGLINE}" == *"Debian GNU/Linux 7 debian-powerpc"* ]] && pkill -P $$ tail
done

echo "Done."

ssh_cmd () {
    sshpass -p 'root' ssh -t -oLogLevel=QUIET -oStrictHostKeyChecking=no 127.0.0.1 -p 22125 -l root "$1"
}

ssh_cmd "echo \"host0 $DIR 9p trans=virtio,version=9p2000.L   0 0\" >> /etc/fstab"
ssh_cmd "mkdir $DIR"
ssh_cmd "mount $DIR"
ssh_cmd "ls $DIR"
ssh_cmd "arch"
ssh_cmd "uname -a"
ssh_cmd "cat /proc/cpuinfo"

echo "SETUP is done!"
