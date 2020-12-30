#!/bin/bash
set -o errtrace
set -o functrace
set -o errexit
set -o nounset
set -o pipefail
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
if [ -n "$(command -v apt-get)" ]; then
  # echo "*** Detected apt-based Linux"
  export DEBIAN_FRONTEND=noninteractive
  sudo apt update -qq > /dev/null 2>&1
  sudo apt install -yqq git > /dev/null 2>&1
fi
if [ -n "$(command -v go)" ]; then
  echo "*** go toolchain detected. building levant from source"
  export GO111MODULE=on
  go get -u github.com/hashicorp/levant > /dev/null 2>&1
  sudo mv $(go env GOPATH)/bin/levant /usr/local/bin/levant
else 
  echo "*** go toolchain not found. downloading latest release from git"
  if [ -n "$(command -v apt-get)" ]; then
    sudo apt update -qq > /dev/null 2>&1
    sudo apt install -yqq curl jq wget > /dev/null 2>&1
  fi
  curl -sL https://api.github.com/repos/hashicorp/levant/releases/latest | jq -r '.assets[]|select(.browser_download_url | (contains("linux") and contains("amd64") and (contains("sha256") | not))).browser_download_url' | xargs -I {} \
    sudo wget --quiet --no-cache -O /usr/local/bin/levant {}
  sudo chmod +x /usr/local/bin/levant
fi
source ~/.profile
levant --version
