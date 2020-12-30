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
  if [ -n "$(command -v node)" ]; then
    echo "*** node $(node --version) is installed"
  else
    wget -qO- https://deb.nodesource.com/setup_12.x | sudo bash - >/dev/null 2>&1
    sudo apt-get install -yqq nodejs >/dev/null 2>&1
  fi
  if [ -n "$(command -v yarn)" ]; then
    echo "*** yarn $(yarn --version) is installed"
  else
    curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - >/dev/null 2>&1 
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list > /dev/null
    sudo apt-get update -qq > /dev/null 2>&1
    sudo apt-get install -yqq yarn >/dev/null 2>&1
  fi
fi


