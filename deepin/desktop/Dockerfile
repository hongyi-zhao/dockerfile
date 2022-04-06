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
    apt update && apt install -y debootstrap && \
    # 对debootstrap打补丁
    ln -sf /usr/share/debootstrap/scripts/stable /usr/share/debootstrap/scripts/$DEEPIN_RELEASE && \
    # 获取根文件系统
    #--include=alpha,beta
    # Comma separated list of packages which will be added to download and extract lists.
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
LABEL maintainer="Hongyi Zhao <hongyi.zhao@gmail.com>"

# 提取rootfs
COPY --from=builder /rootfs /

#https://docs.docker.com/engine/reference/builder/#env
#The ENV instruction allows for multiple <key>=<value> ... variables to be set at one time
ENV SHELL=/bin/bash \
    LANG=en_US.UTF-8

# Some appstore related packages
RUN apt -y update && \
    env DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends --no-install-suggests \
        deepin-app-store \
        deepin-appstore \
        deepin-home-appstore-daemon && \
    apt clean

RUN apt -y update && \
    env DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends --no-install-suggests \
        # basics
        sudo apt-transport-https systemd ca-certificates dbus-x11 deepin-keyring gnupg libcups2 \
        libpulse0 libxv1 locales-all mesa-utils mesa-utils-extra procps psmisc xdg-utils \
        x11-xkb-utils x11-xserver-utils \
        # Some additional tools:
        iproute2 iptables iputils-ping iputils-tracepath \
        openssh-server openssh-client dnsutils net-tools netcat traceroute \
        ncat socat connect-proxy haproxy tcpdump pv iftop iperf3 firefox-esr \
        build-essential gcc make cmake git curl gawk \
        apt-file apt-transport-https apt-utils gdebi synaptic \
        bash-completion libpulse0 pulseaudio \
        uuid equivs unrar lsb-release \
        xfonts-wqy fonts-wqy-microhei fonts-wqy-zenhei nano gedit gedit-plugins vim xclip xsel \
        flameshot gimp && \
    apt clean
       
#https://www.programmersought.net/article/327583873.html
#https://askubuntu.com/questions/1241362/fix-package-post-installation-script-subprocess-returned-error-exit-status-10-fo
#https://serverok.in/apt-post-installation-script-error
#Errors were encountered while processing:
# udisks2
#E: Sub-process /usr/bin/dpkg returned an error code (1)
#https://github.com/hongyi-zhao/dockerfile/issues/1#issuecomment-1085819938        
RUN apt -y update && \
    env DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends --no-install-suggests \
        udisks2 || \
    rm /var/lib/dpkg/info/udisks2* && \
    dpkg --configure -a && \
    env DEBIAN_FRONTEND=noninteractive apt -f install
 
#The following is a list of related DDE packages, but they should be the most basic core packages.
# https://www.deepin.org/en/dde/
#dde-file-manager \
#dde-control-center \
#dde-launcher \
#dde-dock \
#dde-kwin

# Deepin desktop
#https://github.com/mviereck/test/blob/bd1cf7f313e85827274da40ae12ea0c99dd4f0cd/Dockerfile#L103
#https://github.com/mviereck/dockerfile-x11docker-deepin/blob/1267c2f20adacf2b0a96b1786bded22b75ff6ba6/Dockerfile#L121
#https://groups.google.com/g/comp.unix.shell/c/86z967wGrBE/m/XxlvCDv3CAAJ
#$ sudo mount deepin-desktop-community-20.5-amd64.iso /mnt
#$ { echo '{'; cat /mnt/live/packages_choice.json; } | jq -r '.dde[]' | egrep -v '^(dde|plymouth-.*|dde-session-.*|network-manager-.*)$' | awk '{line[NR]=$0} END {for (i=1;i<=length(line);i++) {if (i == 1 ) {print "env DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends --no-install-suggests"" \\\n"line[i]" \\"} else { if (i == length(line)) { print line[i]" && apt clean" } else { print line[i]" \\"}}}}'
RUN apt -y update && \
    env DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends --no-install-suggests \
        deepin-desktop-server \
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
        deepin-terminal && apt clean

CMD ["startdde"]
