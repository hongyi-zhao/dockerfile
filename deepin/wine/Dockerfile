#https://www.jeffgeerling.com/blog/2017/use-arg-dockerfile-dynamic-image-specification
ARG DEEPIN_BASE_IMAGE
FROM $DEEPIN_BASE_IMAGE
#The following variables only existing in the current stage during the building time: 
ARG OPENSOURCE_MIRROR
ARG DEEPIN_REPOSITORY
ARG DEEPIN_APPSTORE_REPOSITORY
ARG DEEPIN_PRINTER_REPOSITORY
ARG DEEPIN_RELEASE
ARG DEEPIN_PRINTER_RELEASE
ARG DEEPIN_APPSTORE_RELEASE

# The variables defined with ENV will be available after the image has been built:
# Choose a deepin mirror close to your location.
# Many further mirrors are listed at: https://www.deepin.org/en/mirrors/packages

#https://github.com/mviereck/dockerfile-x11docker-deepin/issues/29#issuecomment-734294959
#I've added this to x11docker, always done now without an option. So it fixes x11docker/cinnamon and x11docker/gnome as well.
#Note that this needs xrandr / package x11-xserver-utils in image.

#The variables introduced by env command only available in the layer of this RUN instruction:
#Used the command similar to the folloiwng for testing specific applications in the container before putting them into Dockerfile.
# sudo apt-get -o Acquire::http::proxy="socks5h://127.0.0.1:18888/" install com.tencent.meeting.deepin

#Based on my tries, it seems that the method based on HKP protocol has a higher success rate.
# It seems that the options --recv and --recv-keys are equivalent.
#$ bhgrep 1C30362C0A53D5BB|grep ^0|grep -v grep|cut -d ' ' -f4- |awk '!a[$0]++'
#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1C30362C0A53D5BB
#sudo apt-key adv --keyserver attester.flowcrypt.com --recv-keys 1C30362C0A53D5BB
#sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 1C30362C0A53D5BB
#sudo apt-key adv --keyserver hkp://attester.flowcrypt.com --recv-keys 1C30362C0A53D5BB
#sudo apt-key adv --keyserver hkp://attester.flowcrypt.com:80 --recv-keys 1C30362C0A53D5BB
#sudo apt-key adv --keyserver hkps://keyserver.ubuntu.com:443 --recv-keys 1C30362C0A53D5BB
#sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 1C30362C0A53D5BB


RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 1C30362C0A53D5BB && \
    echo "deb ${DEEPIN_REPOSITORY} ${DEEPIN_RELEASE} main contrib non-free\n\
deb-src ${DEEPIN_REPOSITORY} ${DEEPIN_RELEASE} main contrib non-free\n\
deb ${DEEPIN_PRINTER_REPOSITORY} ${DEEPIN_PRINTER_RELEASE} non-free\n\
deb ${DEEPIN_APPSTORE_REPOSITORY} ${DEEPIN_APPSTORE_RELEASE} appstore\n\
" > /etc/apt/sources.list && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests \
        com.qq.weixin.deepin \
        com.qq.im.deepin \
        com.tencent.meeting.deepin \
        fcitx fcitx-googlepinyin fcitx-module-cloudpinyin && \
        apt-get clean
        
RUN if ! [ /opt/apps/com.qq.weixin.deepin/entries/applications/com.qq.weixin.deepin.desktop -ef /usr/share/applications/com.qq.weixin.deepin.desktop ]; then \
      cp -f /opt/apps/com.qq.weixin.deepin/entries/applications/com.qq.weixin.deepin.desktop /usr/share/applications; \
    fi && \
    if ! [ /opt/apps/com.qq.im.deepin/entries/applications/com.qq.im.deepin.desktop -ef /usr/share/applications/com.qq.im.deepin.desktop ]; then \
      cp -f /opt/apps/com.qq.im.deepin/entries/applications/com.qq.im.deepin.desktop /usr/share/applications; \
    fi && \
    if ! [ /opt/apps/com.tencent.meeting.deepin/entries/applications/com.tencent.meeting.deepin.desktop -ef /usr/share/applications/com.tencent.meeting.deepin.desktop ]; then \
      cp -f /opt/apps/com.tencent.meeting.deepin/entries/applications/com.tencent.meeting.deepin.desktop /usr/share/applications; \
    fi


#https://github.com/mviereck/dockerfile-x11docker-deepin/issues/31#issuecomment-734367547
#With option --home the setting is stored (has been before, too), but now it immediatly works after startup without running the config gui again.
# fcitx: Chinese input support
ENV XMODIFIERS=@im=fcitx QT4_IM_MODULE=fcitx QT_IM_MODULE=fcitx GTK_IM_MODULE=fcitx
RUN mkdir -p /etc/xdg/autostart && \
    echo "[Desktop Entry]\n\
Encoding=UTF-8\n\
Version=0.9.4\n\
Type=Application\n\
Name=fcitx\n\
Comment=\n\
Exec=/usr/bin/fcitx-autostart\n\
" > /etc/xdg/autostart/fcitx.desktop

    
#https://github.com/mviereck/dockerfile-x11docker-deepin/issues/36    
#The cleanup script will destroy the cache used by synaptic.
 

#https://github.com/mviereck/dockerfile-x11docker-deepin/issues/31#issue-751290086 
#[Solved] The method for extending fcitx with fcitx-cloudpinyin support used by the deepin base image. 
#I've solved the problem. Both of the following methods can do the trick.

#1. Install the fcitx-module-cloudpinyin package shipped in the deepin repo. 

#2. Compile the module based on its latest git master source code as following.
# 
#```
#$ sudo apt install build-essential cmake fcitx-libs-dev libcurl4-openssl-dev
#$ git clone https://github.com/fcitx/fcitx-cloudpinyin.git fcitx/fcitx-cloudpinyin.git
#$ cd fcitx/fcitx-cloudpinyin.git/
#$ mkdir build
#$ cd build/
#$ cmake ..
#$ make
#$ sudo cp src/fcitx-cloudpinyin.so /usr/lib/x86_64-linux-gnu/fcitx/
#```

  
   
# For apricot:
#https://github.com/mviereck/dockerfile-x11docker-deepin/issues/25#issuecomment-732643390

#https://www.deepin.org/zh/2020/08/06/deepin-system-updates-2020-08-06/
#werner@d58a9acb7441:~$ cat /etc/apt/sources.list.d/appstore.list 
#deb https://community-store-packages.deepin.com/appstore eagle appstore
#$ sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1C30362C0A53D5BB
# The package names have been changed into the folloiwng:   
#com.qq.weixin.deepin com.qq.im.deepin  

#https://deepinenespañol.org/en/improve-the-speed-of-the-deepin-20-beta-repository/
#usuario@deepin20beta:~$ cat /etc/apt/sources.list
### Generated by deepin-installer
##deb [by-hash=force] https://community-packages.deepin.com/deepin/ apricot main contrib non-free
#deb [by-hash=force] https://mirror.deepines.com/testing/deepin-20-beta/ apricot main contrib non-free
##deb-src https://community-packages.deepin.com/deepin/ apricot main contrib non-free
#usuario@deepin20beta:~$ cat sources.list.d/appstore.list 
##deb https://community-store-packages.deepin.com/appstore eagle appstore
#deb https://mirror.deepines.com/testing/appstore eagle appstore 

    
#RUN dpkg --add-architecture i386 && apt-get update && \
#    apt-get install -y iproute2 iptables \
#    iputils-ping iputils-tracepath dnsutils net-tools netcat socat haproxy \
#    gcc make cmake git curl gawk uuid apt-file bash-completion \
#    gdebi synaptic equivs unrar lsb-release apt-utils apt-transport-https openssh-server openssh-client filezilla \
#    xfonts-wqy fonts-wqy-microhei fonts-wqy-zenhei nano gedit gedit-plugins vim xclip xsel \
#    deepin-wine deepin-wine32 deepin-wine32-preloader deepin-wine-helper deepin-wine-uninstaller com.qq.weixin.deepin com.qq.im.deepin
    
    

#https://github.com/mviereck/dockerfile-x11docker-deepin/issues/2#issuecomment-699642969
#https://github.com/mviereck/dockerfile-x11docker-deepin/issues/5#issuecomment-716118596
#https://github.com/mviereck/dockerfile-x11docker-deepin/issues/14

#https://github.com/mviereck/dockerfile-x11docker-deepin/issues/14#issuecomment-723554767

#    The CMD instruction in your wechat image executes the deepin desktop.
#    So either run with option --desktop or specify a command to execute after the image name.
#    Use --xephyr instead of --nxagent to run the deepin desktop.

#https://github.com/mviereck/dockerfile-x11docker-deepin/issues/14#issuecomment-723623469
#Compare the syntax explained in x11docker --help:

#Usage:
#To run a Docker container on a new X server:
#  x11docker IMAGE
#  x11docker [OPTIONS] IMAGE [COMMAND]
#  x11docker [OPTIONS] -- IMAGE [COMMAND [ARG1 ARG2 ...]]
#  x11docker [OPTIONS] -- DOCKER_RUN_OPTIONS -- IMAGE [COMMAND [ARG1 ARG2 ...]]

#Custom docker run options are encapsulated in two --.

# Build the image:
#Please ensure docker0 has enabled with the following ip address,
#https://github.com/mviereck/dockerfile-x11docker-deepin/issues/18
#This maybe a bug of docker itself. Anyway, currently, the following method can be used as an expediency:
# This method don't need to restart docker service.
# Run the following check with socks5-haproxy.sh script periodically in background.
#while :; do
#  if ! ip a show docker0 | grep -qE '^[ ]*inet 172\.17\.0\.1/16'; then
#    sudo ip addr add 172.17.0.1/16 dev docker0
#    sleep 1
#  fi
#done


# Build the image:
#$ docker build --network host -f Dockerfiles/deepin-wine . -t hongyi-zhao/deepin-wine

# Run it as below:
#$ sudo apt-get install xclip xsel
#https://github.com/mviereck/dockerfile-x11docker-deepin/issues/14#issuecomment-723617936
#https://github.com/mviereck/dockerfile-x11docker-deepin/issues/19#issuecomment-724662450
#https://github.com/mviereck/dockerfile-x11docker-deepin/issues/10#issuecomment-724745436
#You should never use --cap-add=ALL as a solution for anything. It is a security leak. If at all, try to find the one capability that is needed, read about it and assess if it is worth the security risk.

#$ x11docker --sudouser -c --hostnet --keepcache --desktop --init=systemd -- --cap-add=ALL --security-opt seccomp=unconfined -- hongyi-zhao/deepin-wine startdde
#$ x11docker --sudouser -c --hostnet --desktop --init=systemd -- --cap-add ALL --security-opt seccomp=unconfined -- hongyi-zhao/deepin-wine startdde


#https://github.com/mviereck/dockerfile-x11docker-deepin/issues/12
#Normally x11docker removes the container afterwards. There is an undocumented option --keepcache that I use sometimes for debugging. It preserves the cache files and the container.

#Ok, than I remembered wrong. Than the command would look like

#docker commit containerid newimagename

#Better ways to store user data are options --home and --share.


#https://github.com/mviereck/x11docker/issues/288#issuecomment-706610847
#x11docker is not designed to start already existing containers. There is a docker issue re-using X unix sockets.

#However, you can create a new image from an existing container with docker commit: https://docs.docker.com/engine/reference/commandline/commit/
#You can run x11docker with this new image.

#I do not recommend this way but rather to set up a Dockerfile containing everything needed. But it is possible to do so, though.


#https://stackoverflow.com/questions/44246586/how-to-list-images-and-their-containers
#$ x11docker --sudouser -c --hostnet --keepcache --desktop --init=systemd -- --cap-add=ALL --security-opt seccomp=unconfined -- hongyi-zhao/deepin-wine startdde
# Find the container created by the above image running:
#$ docker ps -a --format="container:{{.ID}} image:{{.Image}}"
# The following command can be used to the containers displayed with user friendly names: 
#$ docker container commit <tab>
#$ docker commit <tab>
# Create a new image from a container's changes
# Based on my testings, this method can save the self customized configuration files, say, /etc/sudoers.d/nopasswd.
#$ docker container commit x11docker_X110_hongyi-zhao-deepin-wine-startdde_53082129703 hongyi-zhao/deepin-wine-test


