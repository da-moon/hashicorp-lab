#!/bin/bash
set -o errtrace
set -o functrace
set -o errexit
set -o nounset
set -o pipefail
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
if ! grep -q "local/bin" ~/.profile; then
  echo "export PATH=$PATH:$HOME/.local/bin" | tee -a ~/.profile > /dev/null
  source ~/.profile
fi
if [ -n "$(command -v apt-get)" ]; then
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update -qq > /dev/null 2>&1
  sudo apt-get install -y build-essential libssl-dev libffi-dev gcc libpq-dev curl wget > /dev/null 2>&1
  sudo apt-get install -y python python3  > /dev/null 2>&1
  sudo apt-get install -y python-dev python3-dev > /dev/null 2>&1
  sudo apt-get install -y python-pip python3-pip > /dev/null 2>&1
  sudo apt-get install -y python-setuptools python3-setuptools > /dev/null 2>&1
  sudo apt-get install -y virtualenv python3-venv > /dev/null 2>&1
fi
sudo python3 -m pip install yq
