# Validate the dockerfile

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
     
# Run with x11docker

Use [x11docker](https://github.com/mviereck/x11docker) to run [deepin desktop](https://www.deepin.org) in a Docker container. The docker images based on the Dockerfiles in this repo will be generated automatically on [Docker hub](https://hub.docker.com/repositories/docker/hongyizhao) triggered by hook scripts after each commit.

Run desktop with:
```
$ x11docker --desktop --init=systemd -- --cap-add=IPC_LOCK -- hongyizhao/deepin-wine
```

Run single application:
```
$ x11docker hongyizhao/deepin-wine deepin-terminal
```

# Extend the base image
To add your desired applications, create and build from a custom Dockerfile with this image as a base. Example with `firefox`:
```
FROM x11docker/deepin
RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y firefox && \
    apt-get clean
```

## Deepin repository
See [here](https://www.deepin.org/en/mirrors/packages/) for [the official packages repository](https://community-packages.deepin.com/deepin/) and the community packages repository mirrors.
```
FROM x11docker/deepin

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1C30362C0A53D5BB && \
    echo "deb https://community-packages.deepin.com/deepin apricot main contrib non-free"  > /etc/apt/sources.list && \
    echo "deb-src https://community-packages.deepin.com/deepin apricot main contrib non-free"  >> /etc/apt/sources.list && \
    apt-get update
```


Many deepin wine applications need `i386` architecture support. Add this with:
```
RUN dpkg --add-architecture i386 && apt-get update
```

To install e.g. wechat and qq:

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

# Screenshot

![screenshot](https://raw.githubusercontent.com/mviereck/x11docker/screenshots/screenshot-deepin.png "deepin desktop running in Weston+Xwayland window using x11docker")
