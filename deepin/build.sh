#!/usr/bin/env bash

. environment

docker build --network host --build-arg http_proxy='' --build-arg https_proxy='' \
             --build-arg DEEPIN_MIRROR=${DEEPIN_MIRROR} \
             --build-arg DEEPIN_RELEASE=${DEEPIN_RELEASE} \
             -t hongyizhao/deepin:${DEEPIN_RELEASE} -f base/Dockerfile

docker build --network host --build-arg http_proxy='' --build-arg https_proxy='' \
             --build-arg DEEPIN_MIRROR=${DEEPIN_MIRROR} \
             --build-arg DEEPIN_RELEASE=${DEEPIN_RELEASE} \
             -t hongyizhao/deepin-wine:${DEEPIN_RELEASE} -f wine/Dockerfile
