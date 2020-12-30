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
packages=(
  "gnocchiclient"
  "os-client-config"
  "python-barbicanclient"
  "python-ceilometerclient"
  "python-cinderclient"
  "python-glanceclient"
  "python-keystoneclient"
  "python-mistralclient"
  "python-neutronclient"
  "python-novaclient"
  "python-octaviaclient"
  "python-openstackclient"
  "python-swiftclient"
  "python-troveclient"
)
python3 -m pip -q install --no-warn-script-location "${packages[@]}" > /dev/null 2>&1
#python3 -m pip install --no-warn-script-location "${packages[@]}"
