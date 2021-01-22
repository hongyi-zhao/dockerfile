#!/usr/bin/env bash

script_realpath="$(realpath -e -- "${BASH_SOURCE[0]}")"
script_dirname=$(
cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" &&
pwd -P
)
script_name=$(basename -- "${BASH_SOURCE[0]}")

pkg_repo=${script_realpath%.*}
script_realdirname=${script_realpath%/*}
script_realname=${script_realpath##*/}
script_realbasename=${script_realname%.*}
script_realextname=${script_realname##*.}

script_path=$script_dirname/$script_name
script_basename=${script_name%.*}
script_extname=${script_name##*.}

#The docker images can be created on locale host with:
#git clone https://github.com/hongyi-zhao/dockerfile.git dockerfile.git
#cd dockerfile.git/x11docker-deepin.git
. $script_realdirname/hooks/environment
docker build --network host --build-arg http_proxy='' --build-arg https_proxy='' \
             --build-arg DEEPIN_MIRROR=${DEEPIN_MIRROR} \
             --build-arg DEEPIN_APPSTORE_MIRROR=${DEEPIN_APPSTORE_MIRROR} \
             --build-arg DOCKER_TAG=${DOCKER_TAG} \
             --build-arg DEEPIN_RELEASE=${DEEPIN_RELEASE} \
             -t hongyizhao/deepin:${DOCKER_TAG} .

