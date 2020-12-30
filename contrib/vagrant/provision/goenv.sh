#!/usr/bin/env bash
set -o errtrace
set -o functrace
set -o errexit
set -o nounset
set -o pipefail
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
if [ -n "$(command -v apt-get)" ]; then
  # echo "*** Detected apt-based Linux"
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update -qq > /dev/null 2>&1
  sudo apt-get install -yqq git > /dev/null 2>&1
fi
if [ -n "$(command -v goenv)" ]; then
  echo "*** goenv is already installed"
else
  [ -r ~/.goenv ] || git clone https://github.com/syndbg/goenv.git ~/.goenv > /dev/null 2>&1
  if ! grep -q "goenv" ~/.profile; then
    echo 'git -C ~/.goenv pull > /dev/null 2>&1' | tee -a ~/.profile > /dev/null
    echo 'export GOENV_ROOT="$HOME/.goenv"' | tee -a ~/.profile > /dev/null
    echo 'export PATH="$PATH:$GOENV_ROOT/bin"' | tee -a ~/.profile > /dev/null
    echo 'eval "$(goenv init -)"' | tee -a ~/.profile > /dev/null
    source ~/.profile
  fi
fi
if [ -n "$(command -v go)" ]; then
  echo "*** go is already installed"
  exit 0
else
  goenv install 1.15.5 || true
  goenv global 1.15.5 || true
  echo 'export PATH="$PATH:$GOROOT/bin"' | tee -a ~/.profile > /dev/null
  echo 'export PATH="$PATH:$GOPATH/bin"' | tee -a ~/.profile > /dev/null
  echo 'export GO111MODULE=on' | tee -a ~/.profile > /dev/null
  source ~/.profile
  go env > /dev/null && exit 0 || exit 1
fi
