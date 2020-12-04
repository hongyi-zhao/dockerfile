#!/usr/bin/env bash
script_realpath="$(realpath -e -- "${BASH_SOURCE[0]}")"

topdir=$(
cd -P -- "$(dirname -- "$script_realpath")" &&
pwd -P
) 


#The docker images can be created on locale host with:
#git clone https://github.com/hongyi-zhao/dockerfile.git dockerfile.git
#cd dockerfile.git/x11docker-deepin.git
. $topdir/hooks/environment
docker build --network host --build-arg http_proxy='' --build-arg https_proxy='' \
             --build-arg DEEPIN_MIRROR=${DEEPIN_MIRROR} \
             --build-arg DEEPIN_APPSTORE_MIRROR=${DEEPIN_APPSTORE_MIRROR} \
             --build-arg DOCKER_TAG=${DOCKER_TAG} \
             --build-arg DEEPIN_RELEASE=${DEEPIN_RELEASE} \
             -t hongyizhao/deepin:${DOCKER_TAG} .

