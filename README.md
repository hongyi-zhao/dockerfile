# Check the dockerfile

With [hadolint](https://github.com/hadolint/hadolint/issues/506).
```
docker run --rm -i hadolint/hadolint < Dockerfile
```
With [dockerfilelint](https://github.com/replicatedhq/dockerfilelint).
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
     
# x11docker/deepin

Run [deepin desktop](https://www.deepin.org) in a Docker container. 
Use [x11docker](https://github.com/mviereck/x11docker) to run image. 

The docker images based on the Dockerfiles in this repo will be generated automatically on [Docker hub](https://hub.docker.com/repositories/docker/hongyizhao) triggered by hook scripts after each commit.

Run desktop with:
```
x11docker --desktop --init=systemd -- --cap-add=IPC_LOCK -- x11docker/deepin
```

Run single application:
```
x11docker x11docker/deepin deepin-terminal
```

# Options:
 - Persistent home folder stored on host with   `--home`
 - Shared host file or folder with              `--share PATH`
 - Hardware acceleration with option            `--gpu`
 - Clipboard sharing with option                `--clipboard`
 - Language locale setting with                 `--lang [=$LANG]`
 - Sound support with                           `--pulseaudio`
 - Printer support with                         `--printer`
 - Webcam support with                          `--webcam`

See `x11docker --help` for further options.

# Known issues
 - The logout button does not respond. To terminate the session either close the X server window or type `systemctl poweroff` in terminal.
 - Configuring the keyboard input method in deepin control center does not work. Use "Fcitx Configuration" in the application menu instead.

# Extend base image
To add your desired applications, create and build from a custom Dockerfile with this image as a base. Example with `firefox`:
```
FROM x11docker/deepin
RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y firefox && \
    apt-get clean
```

## deepin repository
Some applications has been outsourced from the official deepin repository, noteable many Windows applications running with wine.
They are still available in a [community repository](https://www.deepin.org/en/2020/11/19/statements/).
Another community repository outside of China is [located in Spain](https://deepinenespañol.org/en/improve-the-speed-of-the-deepin-20-beta-repository/).
For new image building, the following repositories can be used, see [here](https://github.com/mviereck/dockerfile-x11docker-deepin/issues/38#issuecomment-737253563) for more infomation:
```
FROM x11docker/deepin

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1C30362C0A53D5BB && \
    echo "deb https://mirrors.ustc.edu.cn/deepin apricot main contrib non-free"  > /etc/apt/sources.list && \
    echo "deb https://mirror.deepines.com/testing/appstore apricot appstore" > /etc/apt/sources.list.d/appstore.list && \
    apt-get update
```


Many deepin wine applications need `i386` architecture support. Add this with:
```
RUN dpkg --add-architecture i386 && apt-get update
```

To install e.g. WeChat add this line:
```
RUN env DEBIAN_FRONTEND=noninteractive apt-get install -y com.qq.weixin.deepin && apt-get clean
```
WeChat can be started in container with: `/opt/apps/com.qq.weixin.deepin/files/run.sh`. To let it appear in the application menu, add:
```
RUN cp /opt/apps/com.qq.weixin.deepin/entries/applications/com.qq.weixin.deepin.desktop /usr/share/applications/
```

# Screenshot

![screenshot](https://raw.githubusercontent.com/mviereck/x11docker/screenshots/screenshot-deepin.png "deepin desktop running in Weston+Xwayland window using x11docker")
