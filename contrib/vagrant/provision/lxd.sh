#!/bin/bash
set -o errtrace
set -o functrace
set -o errexit
set -o nounset
set -o pipefail
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
export DEFAULT_USER=vagrant
if [ -n "$(command -v apt-get)" ]; then
  # echo "*** Detected apt-based Linux"
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update -qq > /dev/null 2>&1
  sudo apt-get install -yqq snapd >/dev/null 2>&1
fi

getent group lxd > /dev/null || sudo groupadd lxd
sudo usermod --append --groups lxd "$DEFAULT_USER"
if [ ! -n "$(command -v lxc)" ]; then
  if [ -n "$(command -v snap)" ]; then
    sudo snap install core >/dev/null 2>&1 || true
    sudo snap install lxd >/dev/null 2>&1 || true
  fi
  echo "PATH=$PATH:/snap/bin" | sudo tee -a /etc/environment > /dev/null
  echo "export PATH=$PATH:/snap/bin" | sudo tee -a /root/.bashrc > /dev/null
fi
export PATH=$PATH:/snap/bin
sudo /bin/bash << _EOF_
source ~/.bashrc
lxd init \
  --auto \
  --network-address="0.0.0.0" \
  --network-port="8443" \
  --trust-password="$DEFAULT_USER" \
  --storage-backend="btrfs" \
  --storage-create-loop="35" \
  --storage-pool="default" || true
_EOF_
# [NOTE] => needed to allow lxd containers to access internet
sudo iptables -P FORWARD ACCEPT
