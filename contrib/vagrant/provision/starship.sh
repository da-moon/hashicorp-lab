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
fi
curl -fsSL https://starship.rs/install.sh | sudo bash -s -- --force
grep -qF 'starship' ~/.bashrc || echo 'eval "$(starship init bash)"' | tee -a ~/.bashrc > /dev/null
sudo grep -qF 'starship' /root/.bashrc || echo 'eval "$(starship init bash)"' | sudo tee -a /root/.bashrc > /dev/null
