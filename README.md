[![Travis](https://img.shields.io/travis/com/horta/port-of-hmmer.svg)](https://travis-ci.com/horta/port-of-hmmer)


# Usage

```
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
- docker exec -t $TARGET autoconf
- docker exec -t $TARGET ./configure
- docker exec -t $TARGET make

notifications:
  email:
    recipients:
      - danilo.horta@pm.me
    on_success: never
    on_failure: always
```
