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
	osname=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
	osrelease=$(lsb_release -cs)
	curl -fsSL https://download.docker.com/linux/"$osname"/gpg | sudo apt-key add -  >/dev/null 2>&1
	echo "deb [arch=amd64] https://download.docker.com/linux/$osname $osrelease stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get -qq update
	sudo apt-get remove -yqq docker docker-engine docker.io containerd runc >/dev/null 2>&1 || true
	sudo apt-get install -yqq docker-ce docker-ce-cli containerd.io >/dev/null 2>&1
	sudo usermod -aG docker "$DEFAULT_USER"
fi

cat << EOF | sudo -H -u "$DEFAULT_USER" -- /bin/bash
newgrp docker <<_EOF_
docker run --rm hello-world >/dev/null 2>&1
_EOF_
EOF
sudo curl -sL "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
curl -sL https://api.github.com/repos/docker/compose/releases/latest | jq -r ".assets[]|select(.browser_download_url | contains(\"$(uname -s)\") and contains(\"$(uname -m)\") and contains(\"x86_64\") and (contains(\"sha256\")|not)).browser_download_url" | \
	xargs -I {} sudo wget --quiet --no-cache -O /usr/local/bin/docker-compose {}
sudo chmod +x /usr/local/bin/docker-compose 

