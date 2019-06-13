FROM ubuntu:16.04

WORKDIR /root
ENV HOME /root
RUN mkdir /root/bin
ENV PATH="/root/bin:${PATH}"
RUN apt-get -y update
RUN apt-get -y --no-install-recommends install curl gcc ca-certificates autoconf \
  libc6-dev make
ADD sandbox_run /root/bin/sandbox_run
RUN chmod +x /root/bin/sandbox_run
HEALTHCHECK --interval=2s --timeout=3s \
  CMD sandbox_run "pwd" || exit 1
