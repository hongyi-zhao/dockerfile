#!/usr/bin/env bash
#https://refspecs.linuxfoundation.org/FHS_3.0/fhs-3.0.html#usrlibexec
#https://groups.google.com/g/comp.unix.shell/c/2Wvk1O8ReG0
#pyenv.git grep -Po -ihR  '\${bash_source[^}]+}' . | sort -u
#echo ${BASH_SOURCE} ${BASH_SOURCE[*]} ${BASH_SOURCE[@]} ${#BASH_SOURCE[@]} 
#The command `readlink -e' is equivalent to `realpath -e'. 

#https://unix.stackexchange.com/questions/68484/what-does-1-mean-in-a-shell-script-and-how-does-it-differ-from
#I summarized Stéphane Chazelas' answer:

#    ${1:+"$@"}' test if $1 null or unset
#    ${1+"$@"}' test if $1 unset

#man bash
#  Parameter Expansion
#       When  not  performing  substring expansion, using the forms documented below (e.g., :-), bash
#       tests for a parameter that is unset or null.  Omitting the colon results in a test only for a
#       parameter that is unset.

#       ${parameter:-word}
#              Use  Default  Values.  If parameter is unset or null, the expansion of word is substi‐
#              tuted.  Otherwise, the value of parameter is substituted.
#      ${parameter:+word}
#              Use Alternate Value.  If parameter is null or unset, nothing is substituted, otherwise
#              the expansion of word is substituted.

#echo $# ${1:-${BASH_SOURCE[0]}}
#return 0 2>/dev/null || exit 0

#https://groups.google.com/g/comp.unix.shell/c/tof4eopmdU8
#Pure bash shell implementation for: $(basename "${1:-${BASH_SOURCE[0]}}")
unset scriptdir_realpath
unset script_realdirname script_dirname
unset script_realname script_name
unset script_realpath script_path
unset pkg_realpath
unset script_realbasename script_basename
unset script_realextname script_extname


scriptdir_realpath=$(cd -P -- "$(dirname -- "${1:-${BASH_SOURCE[0]}}")" && pwd -P)

script_realdirname=$(dirname "$(realpath -e "${1:-${BASH_SOURCE[0]}}")")
script_dirname=$(cd -- "$(dirname -- "${1:-${BASH_SOURCE[0]}}")" && pwd)

script_realname=$(basename "$(realpath -e "${1:-${BASH_SOURCE[0]}}")")
script_name=$(basename "${1:-${BASH_SOURCE[0]}}")

#https://groups.google.com/g/comp.unix.shell/c/tof4eopmdU8/m/_p9kLoBgCwAJ
#Unfortunately, the #, ##, %% and % operators can't be used with
#general expressions.  They only can be applied to variable names. 
#But you can achieve the wanted result in two steps: 

#script_name="${1:-${BASH_SOURCE[0]}}" && script_name="${script_name2##*/}" 

script_realpath=$script_realdirname/$script_realname
script_path=$script_dirname/$script_name

pkg_realpath=${script_realpath%.*}

script_realbasename=${script_realname%.*}
script_basename=${script_name%.*}

script_realextname=${script_realname##*.}
script_extname=${script_name##*.}


#https://groups.google.com/g/comp.unix.shell/c/2Wvk1O8ReG0/m/pHpdJWiPDgAJ
# Test it with the following code:
#printf "%-16s %s\n" "script_realpath:" $script_realpath
#printf "%-16s %s\n" "pkg_realpath:" $pkg_realpath
#return 0 2>/dev/null || exit 0

#Build the docker image locally from source:
#git clone https://github.com/hongyi-zhao/dockerfile.git dockerfile.git
#cd dockerfile.git/x11docker-deepin-wine
. hooks/environment
docker build --network host --build-arg http_proxy='' --build-arg https_proxy='' \
             --build-arg DEEPIN_MIRROR=${DEEPIN_MIRROR} \
             --build-arg DEEPIN_APPSTORE_MIRROR=${DEEPIN_APPSTORE_MIRROR} \
             --build-arg DOCKER_TAG=${DOCKER_TAG} \
             --build-arg DEEPIN_RELEASE=${DEEPIN_RELEASE} \
             -t hongyizhao/deepin-wine:${DOCKER_TAG} .

