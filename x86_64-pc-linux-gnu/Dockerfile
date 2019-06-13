FROM ubuntu:16.04

WORKDIR /hostdir
ENV HOME /root
RUN apt-get -y update
RUN apt-get -y --no-install-recommends install curl gcc ca-certificates autoconf \
  libc6-dev make git
HEALTHCHECK --interval=2s --timeout=3s \
  CMD pwd || exit 1
