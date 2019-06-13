FROM fedora:30

WORKDIR /root
ENV HOME /root
ADD sha1sum.txt sha1sum.txt
RUN dnf install qemu qemu-system-ppc openssh-clients sshpass -y
RUN curl http://rest.s3for.me/hmmer/debian-wheezy-powerpc.qcow2 \
    --output debian-wheezy-powerpc.qcow2
RUN sha1sum -c sha1sum.txt
ADD setup.sh setup.sh
# CMD ["bash"]
