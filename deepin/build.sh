#!/usr/bin/env bash
. environment

docker build --network host --build-arg http_proxy='' --build-arg https_proxy='' \
             --build-arg OPENSOURCE_MIRROR=${OPENSOURCE_MIRROR} \
             --build-arg DEEPIN_REPOSITORY=${DEEPIN_REPOSITORY} \
             --build-arg DEEPIN_RELEASE=${DEEPIN_RELEASE} \
             -t hongyizhao/deepin-desktop:${DEEPIN_RELEASE} -f desktop/Dockerfile .

docker build --network host --build-arg http_proxy='' --build-arg https_proxy='' \
             --build-arg OPENSOURCE_MIRROR=${OPENSOURCE_MIRROR} \
             --build-arg DEEPIN_REPOSITORY=${DEEPIN_REPOSITORY} \
             --build-arg DEEPIN_APPSTORE_REPOSITORY=${DEEPIN_APPSTORE_REPOSITORY} \
             --build-arg DEEPIN_PRINTER_REPOSITORY=${DEEPIN_PRINTER_REPOSITORY} \
             --build-arg DEEPIN_RELEASE=${DEEPIN_RELEASE} \
             --build-arg DEEPIN_PRINTER_RELEASE=${DEEPIN_PRINTER_RELEASE} \
             --build-arg DEEPIN_APPSTORE_RELEASE=${DEEPIN_APPSTORE_RELEASE} \
             --build-arg DEEPIN_BASE_IMAGE=hongyizhao/deepin-desktop:${DEEPIN_RELEASE} \
             -t hongyizhao/deepin-wine:${DEEPIN_RELEASE} -f wine/Dockerfile .
