#!/bin/bash
set -o errtrace
set -o functrace
set -o errexit
set -o nounset
set -o pipefail
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
# passwordless sudo
sudo sed -i.bak -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers
if [ -n "$(command -v apt-get)" ]; then
  # echo "*** Detected apt-based Linux"
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update -qq > /dev/null 2>&1
  sudo apt-get install -yqq \
    apt-utils net-tools lsof apt-transport-https \
    curl gnupg2 tree jq gnupg2 ntp htop sshpass \
    ufw dstat bash-completion unzip zip iperf \
    software-properties-common netcat lsof \
    sysstat make build-essential rsync ca-certificates git \
    lsb-release aria2 xfonts-utils tmate ncdu neofetch >/dev/null 2>&1
fi
sudo sed -i -e '/net.ipv4.ip_forward=/d' /etc/sysctl.conf > /dev/null
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf > /dev/null
sudo sed -i -e '/PermitRootLogin/d' /etc/ssh/sshd_config > /dev/null
echo 'PermitRootLogin no' | sudo tee -a /etc/ssh/sshd_config > /dev/null
sudo mv -f /tmp/bin/* /usr/local/bin/
sudo chmod +x /usr/local/bin/*
