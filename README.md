## Portability of HMMER

[![Travis](https://img.shields.io/travis/com/horta/port-of-hmmer.svg)](https://travis-ci.com/horta/port-of-hmmer)

We provide tools to help test HMMER software on different platforms.
As of now, we have docker images and scripts to be used with the Travis CI services.

## Usage

```yaml
# .travis.yml
language: minimal

services:
  - docker

env:
  global:
    - PATH=$HOME/bin:$PATH

matrix:
  include:
    - env: TARGET=x86_64-pc-linux-gnu
      name: x86_64-pc-linux-gnu
    - env: TARGET=powerpc-unknown-linux-gnu
      name: powerpc-unknown-linux-gnu
    - os: osx
      env: TARGET=x86_64-apple-darwin
      name: x86_64-apple-darwin

before_install:
  - bash <(curl -fsSL https://raw.githubusercontent.com/horta/port-of-hmmer/master/ci/travis.sh)

script:
  - sandbox_run git clone -b develop https://github.com/EddyRivasLab/easel.git
  - sandbox_run ln -s easel/aclocal.m4 aclocal.m4
  - sandbox_run autoconf
  - sandbox_run ./configure
  - sandbox_run make
  - sandbox_run make check

notifications:
  email:
    recipients:
      - danilo.horta@pm.me
    on_success: never
    on_failure: always
```
