# https://gitee.com/daze456/deepin-desktop-docker
FROM debian AS builder

# 主参数
ARG \
    # deepin代号
    DEEPIN_RELEASE \
    # 软件仓库
    DEEPIN_REPOSITORY \
    OPENSOURCE_MIRROR
    
# 安装debootstrap
RUN \
    sed -ri "s|^(deb(-src)?[[:blank:]]+https?://)([^/]+)|\1${OPENSOURCE_MIRROR}|" /etc/apt/sources.list && \
    apt update && apt install -y debootstrap

RUN \
    # 对debootstrap打补丁
    ln -sf /usr/share/debootstrap/scripts/stable /usr/share/debootstrap/scripts/$DEEPIN_RELEASE && \
    # 获取根文件系统
    debootstrap --no-check-gpg --arch=$(dpkg --print-architecture) --include=bash $DEEPIN_RELEASE /rootfs $DEEPIN_REPOSITORY && \
    # 修复sources.list（启用专有源）
    echo "deb [by-hash=force] ${DEEPIN_REPOSITORY} ${DEEPIN_RELEASE} main contrib non-free\n\
deb-src ${DEEPIN_REPOSITORY} ${DEEPIN_RELEASE} main contrib non-free\n\
" > /rootfs/etc/apt/sources.list && \
    # 清理
    rm -rf /rootfs/var/cache/* /rootfs/tmp/* /rootfs/var/log/*

# 从空镜像开始正式构建
FROM scratch
# 署名
MAINTAINER Hongyi Zhao <hongyi.zhao@gmail.com>
LABEL maintainer="Hongyi Zhao <hongyi.zhao@gmail.com>"

# 提取rootfs
COPY --from=builder /rootfs /

# cleanup script for use after apt-get
RUN echo '#!/bin/sh\n\
env DEBIAN_FRONTEND=noninteractive apt-get autoremove -y\n\
apt-get clean\n\
find /var/lib/apt/lists -type f -delete\n\
find /var/cache -type f -delete\n\
find /var/log -type f -delete\n\
exit 0\n\
' > /cleanup && chmod +x /cleanup


ENV SHELL=/bin/bash
ENV LANG=en_US.UTF-8

# basics
RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        dbus-x11 \
        deepin-keyring \
        gnupg \
        libcups2 \
        libpulse0 \
        libxv1 \
        locales-all \
        mesa-utils \
        mesa-utils-extra \
        procps \
        psmisc \
        xdg-utils \
        x11-xkb-utils \
        x11-xserver-utils \
        sudo && \
    /cleanup
    
# Some additional tools:
RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y \
        iproute2 iptables iputils-ping iputils-tracepath \
        openssh-server openssh-client dnsutils net-tools netcat traceroute \
        ncat socat connect-proxy haproxy tcpdump pv iftop iperf3 firefox-esr \
        build-essential gcc make cmake git curl gawk \
        apt-file apt-transport-https apt-utils gdebi synaptic \
        bash-completion libpulse0 pulseaudio \
        uuid equivs unrar lsb-release \
        xfonts-wqy fonts-wqy-microhei fonts-wqy-zenhei nano gedit gedit-plugins vim xclip xsel && \
    /cleanup


# Replace closed source package deepin-user-experience-daemon (spyware?) with an empty fake package.
# https://github.com/mviereck/dockerfile-x11docker-deepin/issues/33
RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y \
        equivs && \
    echo "Section: misc\n\
Priority: optional\n\
Standards-Version: 3.9.2\n\
Package: deepin-user-experience-daemon\n\
Version: 99.0\n\
Provides: deepin-user-experience-daemon\n\
" > deepin-user-experience-daemon && \
    equivs-build deepin-user-experience-daemon && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ./deepin-user-experience-daemon_99.0_all.deb && \
    apt-get remove -y \
        equivs && \
    rm deepin-user-experience* && \
    /cleanup

# deepin desktop
#https://github.com/mviereck/test/blob/bd1cf7f313e85827274da40ae12ea0c99dd4f0cd/Dockerfile#L103
#https://github.com/mviereck/dockerfile-x11docker-deepin/blob/1267c2f20adacf2b0a96b1786bded22b75ff6ba6/Dockerfile#L121
#https://groups.google.com/g/comp.unix.shell/c/86z967wGrBE/m/XxlvCDv3CAAJ
#$ sudo mount deepin-desktop-community-20.3-amd64.iso /mnt
#$ { echo '{'; cat /mnt/live/packages_choice.json; } | jq -r '.dde[]' |egrep -v '^(dde|plymouth-.*|dde-session-.*|network-manager-.*)$' | awk '{line[NR]=$0} END {for (i=1;i<=length(line);i++) {if (i == 1 ) {print "env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "line[i]" \\"} else { if (i == length(line)) { print line[i]} else { print line[i]" \\"}}}}'
RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends deepin-desktop-server \
        deepin-default-settings \
        dde-desktop \
        dde-dock \
        dde-launcher \
        dde-control-center \
        startdde \
        deepin-artwork \
        dde-file-manager \
        dde-qt5integration \
        deepin-wallpapers \
        fonts-noto \
        dde-introduction \
        dde-kwin \
        deepin-screensaver \
        dde-calendar \
        deepin-terminal && \
    /cleanup

CMD ["startdde"]
