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
rm -rf /tmp/hashicorp && \
mkdir -p /tmp/hashicorp && \
curl -sL "https://releases.hashicorp.com/index.json" | jq -r '[to_entries | map_values(.value + { slug: .key }) |.[].versions | to_entries | map_values(.value + { slug: .key }) | [.[].builds[] | select( (.version | ( contains("ent") or contains("beta") or contains("rc") or contains("techpreview"))|not) and (.os=="linux") and (.arch=="amd64") and (.url | contains("zip")) and (.version | contains("-") | not) and (.name | ( contains("provider") or contains("null") or contains("-"))|not))] | max_by(.version | [splits("[.]")] | map(tonumber))] | del(.[] | nulls) | .[] | "wget --quiet --no-cache -O \"/tmp/hashicorp/\(.name).zip\" \"\(.url)\""' | xargs -I {} -P `nproc` bash -c "{}" && \
pushd /tmp/hashicorp >/dev/null 2>&1 && \
find . -mindepth 1 -maxdepth 1 -type f -name '*.zip' | xargs -I {} -P `nproc` unzip -qq {} && \
rm *.zip && \
sudo mv -f ./* /usr/local/bin/ && \
popd >/dev/null 2>&1
