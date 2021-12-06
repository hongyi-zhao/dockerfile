# x11docker/deepin
# 
# Run deepin desktop in a Docker container. 
# Use x11docker to run image: 
#   https://github.com/mviereck/x11docker 
#
# Run deepin desktop with:
#   x11docker --desktop --init=systemd -- --cap-add=IPC_LOCK -- x11docker/deepin
#
# Run single application:
#   x11docker x11docker/deepin deepin-terminal
#
# Options:
# Persistent home folder stored on host with   --home
# Share host file or folder with option        --share PATH
# Hardware acceleration with option            --gpu
# Clipboard sharing with option                --clipboard
# Language locale setting with option          --lang [=$LANG]
# Sound support with option                    --pulseaudio
# Printer support with option                  --printer
# Webcam support with option                   --webcam
#
# See x11docker --help for further options.

#https://docs.docker.com/engine/reference/commandline/build/#set-build-time-variables---build-arg
#https://docs.docker.com/engine/reference/builder/#arg
#https://docs.docker.com/engine/reference/builder/#scope
#https://docs.docker.com/engine/reference/builder/#using-arg-variables

#### stage 0: debian, debootstrap ####
FROM debian
#The following variables only existing in the current stage during the building time: 
ARG DEEPIN_MIRROR
ARG DEEPIN_RELEASE

# The variables defined with ENV will be available after the image has been built:
# Choose a deepin mirror close to your location.
# Many further mirrors are listed at: https://www.deepin.org/en/mirrors/packages
#ENV DEEPIN_MIRROR=http://mirrors.kernel.org/deepin

#ENV DEEPIN_MIRROR=http://packages.deepin.com/deepin
#ENV DEEPIN_MIRROR=https://community-packages.deepin.com/deepin
#ENV DEEPIN_MIRROR=http://mirrors.ustc.edu.cn/deepin
#ENV DEEPIN_MIRROR=https://mirror.deepines.com/deepin


# prepare sources and keys
#The variables introduced by env command only available in the layer of this RUN instruction:

#$ man apt-key |egrep -A6 '^[ ]*adv'
#       adv
#           Pass advanced options to gpg. With adv --recv-key you can e.g.
#           download key from keyservers directly into the trusted set of keys.
#           Note that there are no checks performed, so it is easy to
#           completely undermine the apt-secure(8) infrastructure if used
#           without care.

#$ man gpg|egrep -- '--(keyserver|recv-keys)' 
#       --recv-keys keyIDs
#                     your  key  from. See --keyserver-options honor-keyserver-
#       --keyserver name
#              This option is deprecated - please use the --keyserver in ‘dirm‐
#              provided.  These  are the same as the global --keyserver-options
#       --keyserver-options {name=value}


RUN sed -ri "s|^(deb(-src)?[[:blank:]]+https?://)([^/]+)|\1$(echo $DEEPIN_MIRROR | cut -d '/' -f3)|" /etc/apt/sources.list && \
    apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y \
        debootstrap \
        gnupg && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 425956BB3E31DF51 && \
    mkdir -p /rootfs/etc/apt && \
    cp /etc/apt/trusted.gpg /rootfs/etc/apt/trusted.gpg && \
    echo "deb     $DEEPIN_MIRROR $DEEPIN_RELEASE main contrib non-free" > /rootfs/etc/apt/sources.list && \
    echo "deb-src $DEEPIN_MIRROR $DEEPIN_RELEASE main contrib non-free" >> /rootfs/etc/apt/sources.list


#https://www.tutorialfor.com/blog-274404.htm
#https://stackoverflow.com/questions/33439230/how-to-write-commands-with-multiple-lines-in-dockerfile-while-preserving-the-new
#https://mihamina.rktmb.org/2016/06/dockerfile-multiline-to-file.html
#https://github.com/moby/moby/issues/1799
#https://github.com/mviereck/dockerfile-x11docker-deepin/issues/41#issuecomment-739184425
#docker build can only read one line. \ disables the newline and allows to read multiple lines. Without this the build would fail, just try out.
#To get newlines with echo in the resulting file I add \n.

#SHELL ["/bin/bash", "-c"]
#RUN echo $"command substitute `hostname -i` \n\
##comment line \n\
#variable expanding or not: \$HOME $HOME \n\
#single and double quote: ' \" \n\
#" > blabla


# cleanup script for use after apt-get
RUN echo '#!/bin/sh\n\
env DEBIAN_FRONTEND=noninteractive apt-get autoremove -y\n\
apt-get clean\n\
find /var/lib/apt/lists -type f -delete\n\
find /var/cache -type f -delete\n\
find /var/log -type f -delete\n\
exit 0\n\
' > /rootfs/cleanup && chmod +x /rootfs/cleanup

# debootstrap script
RUN mkdir -p /usr/share/debootstrap/scripts && \
    echo "mirror_style release\n\
download_style apt\n\
finddebs_style from-indices\n\
variants - buildd fakechroot minbase\n\
. /usr/share/debootstrap/scripts/debian-common\n\
" > /usr/share/debootstrap/scripts/$DEEPIN_RELEASE

RUN debootstrap --variant=minbase --arch=amd64 $DEEPIN_RELEASE /rootfs $DEEPIN_MIRROR && \
    chroot ./rootfs apt-get update && \
    chroot ./rootfs env DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && \
    chroot ./rootfs /cleanup

#### stage 1: deepin ####
FROM scratch
COPY --from=0 /rootfs /

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
        x11-xserver-utils && \
    /cleanup
    
# Some additional tools comes here:
RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y \
        iproute2 iptables iputils-ping iputils-tracepath \
        openssh-server openssh-client dnsutils net-tools netcat traceroute \
        ncat socat connect-proxy haproxy tcpdump pv iftop iperf3 firefox-esr \
        build-essential gcc make cmake git curl gawk \
        apt-file apt-transport-https apt-utils gdebi synaptic \
        bash-completion libpulse0 pulseaudio vlc \
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
# Dependencies taken from 'apt show dde'
# (excluded: dde-session-ui deepin-manual eject plymouth-theme-deepin-logo dde-printer deepin-screensaver)
RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        dde-control-center \
        dde-clipboard \
        dde-desktop \
        dde-dock \
        dde-file-manager \
        dde-kwin \
        dde-launcher \
        dde-qt5integration \
        deepin-artwork \
        deepin-default-settings \
        deepin-desktop-base \
        deepin-wallpapers \
        fonts-noto \
        startdde && \
    /cleanup

# additional applications
RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        dde-calendar \
        deepin-album \
        deepin-calculator \
        deepin-draw \
        deepin-editor \
        deepin-image-viewer \
        deepin-movie \
        deepin-music \
        deepin-screenshot \
        deepin-system-monitor \
        deepin-terminal \
        deepin-voice-note \
        oneko \
        sudo && \
    /cleanup
    
# fcitx: Chinese input support
#ENV XMODIFIERS=@im=fcitx QT4_IM_MODULE=fcitx QT_IM_MODULE=fcitx GTK_IM_MODULE=fcitx
#RUN apt-get update && \
#    env DEBIAN_FRONTEND=noninteractive apt-get install -y \
#        fcitx-sunpinyin && \
#    mkdir -p /etc/xdg/autostart && \
#    echo "[Desktop Entry]\n\
#Encoding=UTF-8\n\
#Version=0.9.4\n\
#Type=Application\n\
#Name=fcitx\n\
#Comment=\n\
#Exec=/usr/bin/fcitx-autostart\n\
#" > /etc/xdg/autostart/fcitx.desktop && \
#    /cleanup

CMD ["startdde"]
