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
rm -rf /tmp/ripgrep*
mkdir -p /tmp/ripgrep
curl -sL https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r '.assets[]|select(.browser_download_url | (contains("linux") and contains("x86_64") and (contains("sha256") | not))).browser_download_url' | xargs -I {} wget --quiet --no-cache -O /tmp/ripgrep.tar.gz {}
sudo tar \
    -xzf /tmp/ripgrep.tar.gz \
    -C /tmp/ripgrep \
    --strip-components=1
sudo mv /tmp/ripgrep/rg /usr/local/bin/rg
sudo mv /tmp/ripgrep/complete/rg.bash  /etc/bash_completion.d/rg.bash
sudo chmod +x /usr/local/bin/rg
sudo rm -r /tmp/ripgrep*
