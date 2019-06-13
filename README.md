[![Travis](https://img.shields.io/travis/com/horta/port-of-hmmer.svg)](https://travis-ci.com/horta/port-of-hmmer)


# Usage

```yaml
language: minimal

services:
  - docker

env:
  matrix:
    - TARGET=powerpc-unknown-linux-gnu

before_install:
- docker pull hortaebi/$TARGET
- docker run -d -v $TRAVIS_BUILD_DIR:/hostdir --name $TARGET -t hortaebi/$TARGET
- docker exec -t $TARGET ./setup.sh

script:
- docker exec -t $TARGET "sshpass -p 'root' ssh -t -oLogLevel=QUIET -oStrictHostKeyChecking=no 127.0.0.1 -p 22125 -l root pwd"
- docker exec -t $TARGET "sshpass -p 'root' ssh -t -oLogLevel=QUIET -oStrictHostKeyChecking=no 127.0.0.1 -p 22125 -l root autoconf"

notifications:
  email:
    recipients:
      - danilo.horta@pm.me
    on_success: never
    on_failure: always
```
