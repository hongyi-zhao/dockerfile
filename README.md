## Validate the dockerfile

With [hadolint](https://github.com/hadolint/hadolint/issues/506):
```
$ docker run --rm -i hadolint/hadolint < Dockerfile
```
With [dockerfilelint](https://github.com/replicatedhq/dockerfilelint):
```
$ sudo apt install npm
$ npm config set proxy http://127.0.0.1:8080
$ npm config set https-proxy http://127.0.0.1:8080
$ sudo npm install -g dockerfilelint
$ cat .npmrc
proxy=http://127.0.0.1:8080/
https-proxy=http://127.0.0.1:8080

$ dockerfilelint < Dockerfile
```

## Deepin repository
See [here](https://github.com/mviereck/dockerfile-x11docker-deepin/issues/25#issuecomment-732643390), [here](https://www.deepin.org/zh/2020/08/06/deepin-system-updates-2020-08-06/), and [here](https://www.deepin.org/en/2020/11/19/statements/) for more detailed infomartion. [The currently used configuration](https://github.com/hongyi-zhao/dockerfile/blob/7556649d60bc8a64693338fe1d965a99db744a09/x11docker-deepin-wine/Dockerfile#L43) is as follows:

```
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 1C30362C0A53D5BB && \
    echo "deb ${DEEPIN_REPOSITORY} ${DEEPIN_RELEASE} main contrib non-free\n\
deb-src ${DEEPIN_REPOSITORY} ${DEEPIN_RELEASE} main contrib non-free\n\
deb https://community-packages.deepin.com/printer eagle non-free\n\
deb https://community-store-packages.deepin.com/appstore apricot appstore\n\
" > /etc/apt/sources.list
```

Many deepin wine applications need `i386` architecture support. Add this with:
```
RUN dpkg --add-architecture i386 && apt-get update
```

To install e.g. wechat and qq

```
$ apt-cache pkgnames |grep -i ^com.qq
com.qq.im.deepin
com.qq.weixin.deepin
```
So the following command should be used:
```
RUN env DEBIAN_FRONTEND=noninteractive apt-get install -y com.qq.im.deepin com.qq.weixin.deepin && apt-get clean
```
WeChat can be started in container with: `/opt/apps/com.qq.weixin.deepin/files/run.sh`. To let it appear in the application menu, add:
```
RUN cp /opt/apps/com.qq.weixin.deepin/entries/applications/com.qq.weixin.deepin.desktop /usr/share/applications/
```

## Build docker images from the Dockerfile manually

```
$ cd deepin && bash build.sh
```

### Extend the base image as you wish:
To add your desired applications, create and build from a custom Dockerfile with this image as a base. Example with `firefox`:
```
FROM hongyizhao/deepin
RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y firefox && \
    apt-get clean
```


## Run the image using x11docker

Use [x11docker](https://github.com/mviereck/x11docker) to run [deepin desktop](https://www.deepin.org) in a Docker container. The docker images based on the Dockerfiles in this repo will be generated automatically on [Docker hub](https://hub.docker.com/repositories/docker/hongyizhao) triggered by hook scripts after each commit.

```
$ . environment
$ pyenv shell 3.9.7
# Run desktop:
$ x11docker --runasroot 'sed -r "s/^[[:blank:]]*[|]//" <<-EOF > /etc/sudoers
        |#$ sudo grep -Ev '\''^[ ]*(#|$)'\'' /etc/sudoers  
        |Defaultsenv_reset
        |Defaultsmail_badpass
        |Defaultssecure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
        |rootlesskitALL=(ALL:ALL) ALL
        |%admin ALL=(ALL) ALL
        |%sudoALL=(ALL:ALL) ALL
        |$USER ALL=(ALL) NOPASSWD:ALL
EOF' --xephyr --network=bridge --pulseaudio --xoverip --home --share=$HOME --sudouser -c --desktop --init=systemd -- --device /dev/mem:/dev/mem --cap-add=ALL -- hongyizhao/deepin-wine:${DEEPIN_RELEASE}

# Run single application:
$ x11docker hongyizhao/deepin-wine deepin-terminal
```
## Screenshot
![image](https://user-images.githubusercontent.com/11155854/144838310-83643432-8871-43a3-905d-d7b51e1c5445.png)

## Run the latest official version of Windows applications, such as wechat, through Deepin-Wine directly (Not recommended)
```
$ Curl -O https://dldir1.qq.com/weixin/Windows/WeChatSetup.exe
$ deepin-wine6-stable WeChatSetup.exe
$ LC_ALL=zh_CN.UTF-8 deepin-wine6-stable ~/.wine/drive_c/Program\ Files/Tencent/WeChat/WeChat.exe
```
## Similar project
- https://gitee.com/daze456/deepin-desktop-docker
- https://github.com/mviereck/dockerfile-x11docker-deepin
- https://github.com/vufa/deepin-wine-wechat-arch

## Application development workflows
- https://github.com/pricing#compare-features
- https://event-driven.io/en/how_to_buid_and_push_docker_image_with_github_actions/
- https://github.com/marketplace/actions/build-and-push-docker-images
- https://docs.github.com/en/actions/creating-actions/creating-a-docker-container-action
- https://docs.github.com/en/actions/publishing-packages/publishing-docker-images


