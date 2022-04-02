## Validate the dockerfile

With [hadolint](https://github.com/hadolint/hadolint/issues/506):
```
$ . deepin/environment 
$ docker run --rm -i hadolint/hadolint < deepin/desktop/Dockerfile
$ docker run --rm -i hadolint/hadolint < deepin/wine/Dockerfile
```
With [dockerfilelint](https://github.com/replicatedhq/dockerfilelint):
```
$ sudo apt install npm
# Use npm through a local proxy:
$ npm config set proxy http://127.0.0.1:8080
$ npm config set https-proxy http://127.0.0.1:8080
$ sudo npm install -g dockerfilelint
$ cat .npmrc
proxy=http://127.0.0.1:8080/
https-proxy=http://127.0.0.1:8080

$ . deepin/environment 
$ dockerfilelint < deepin/desktop/Dockerfile
$ dockerfilelint < deepin/wine/Dockerfile
```

## Repositories
See the [files](https://github.com/hongyi-zhao/dockerfile/tree/master/deepin/etc/apt) obtained from the desktop environment installed with Deepin 64-bit Official ISO Disk Image download from [here](https://cdimage.deepin.com/releases/) or [here](https://www.deepin.org/en/download/).

## Build docker images from the Dockerfile manually

```
$ cd deepin && bash build.sh
```

## Extend the base image as you wish
For the definition of related variables, see [here](https://github.com/hongyi-zhao/dockerfile/blob/master/deepin/environment). Add your desired applications, for example, `firefox`, and build a custom image from a `Dockerfile` based on this one:
```
FROM hongyizhao/deepin-desktop:${DEEPIN_RELEASE}
RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y firefox && \
    apt-get clean
```


## Run the image using x11docker

Use [x11docker](https://github.com/mviereck/x11docker) to run [deepin desktop](https://www.deepin.org) in a Docker container. 

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
$ x11docker hongyizhao/deepin-wine:${DEEPIN_RELEASE} deepin-terminal
```
## Screenshot
![image](https://github.com/hongyi-zhao/dockerfile/blob/master/deepin/screenshot.png)

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
- https://event-driven.io/en/how_to_buid_and_push_docker_image_with_github_actions/
- https://github.com/marketplace/actions/build-and-push-docker-images
- https://docs.github.com/en/actions/creating-actions/creating-a-docker-container-action
- https://docs.github.com/en/actions/publishing-packages/publishing-docker-images
- https://github.com/vufa/deepin-wine-wechat-arch/tree/action/.github/workflows
