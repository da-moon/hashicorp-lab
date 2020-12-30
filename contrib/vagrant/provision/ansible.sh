#!/usr/bin/env bash
set -o errtrace
set -o functrace
set -o errexit
set -o nounset
set -o pipefail
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
if [ -n "$(command -v apt-get)" ]; then
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update -qq > /dev/null 2>&1
  sudo apt-get install -yqq ansible > /dev/null 2>&1
fi
if [ -n "$(command -v ansible-generate)" ]; then
  echo "*** installing ansible generate"
  python3 -m pip -q install --no-warn-script-location "${packages[@]}" > /dev/null 2>&1
fi
[ -r ~/.vault_pass.txt ] || head -c16 </dev/urandom|xxd -p -u | tee ~/.vault_pass.txt > /dev/null
