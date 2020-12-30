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
  sudo apt-get update -qq > /dev/null 2>&1
  sudo apt-get install libssl-dev -yqq > /dev/null 2>&1
fi
rm -rf /tmp/nushell
mkdir -p /tmp/nushell
curl -sL https://api.github.com/repos/nushell/nushell/releases/latest | jq -r '.assets[]|select(.browser_download_url | (contains("linux")  and (contains("sha256") | not))).browser_download_url' | xargs -I {} wget -qO /tmp/nushell/nushell.tar.gz {}
tar \
    -xzf /tmp/nushell/nushell.tar.gz \
    -C /tmp/nushell \
    --strip-components=2
rm -rf /tmp/nushell/nushell.tar.gz
sudo mv /tmp/nushell/nu* /usr/local/bin/
rm -rf /tmp/nushell