#!/usr/bin/env bash
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
  sudo apt-get install -yqq \
  	git curl zlib1g-dev build-essential \
  	libssl-dev libreadline-dev libyaml-dev \
  	libsqlite3-dev sqlite3 libxml2-dev \
  	libxslt1-dev libcurl4-openssl-dev \
  	software-properties-common libffi-dev > /dev/null 2>&1
fi

if [ -n "$(command -v rbenv)" ]; then
  echo "*** rbenv is already installed"
else
  [ -r ~/.rbenv ] || git clone https://github.com/rbenv/rbenv.git ~/.rbenv > /dev/null 2>&1
  [ -r ~/.rbenv/plugins/ruby-build ] || git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build > /dev/null 2>&1
  if ! grep -q "rbenv" ~/.profile; then
    echo 'git -C ~/.rbenv pull > /dev/null 2>&1' | tee -a ~/.profile > /dev/null
    echo 'export PATH="$PATH:$HOME/.rbenv/bin"' | tee -a ~/.profile > /dev/null
    echo 'eval "$(rbenv init -)"' | tee -a ~/.profile > /dev/null
    echo 'export PATH="$PATH:$HOME/.rbenv/plugins/ruby-build/bin"' | tee -a ~/.profile > /dev/null
    source ~/.profile
  fi
fi
if [ -n "$(command -v ruby)" ]; then
  echo "*** $(ruby --version) is installed"
else
  if [ -n "$(command -v rbenv)" ]; then
    rbenv install 2.7.2
    rbenv global 2.7.2
    source ~/.profile
  fi
fi
if [ -n "$(command -v bundler)" ]; then
  echo "*** bundler is already installed"
else
  gem install bundler
  if [ -n "$(command -v rbenv)" ]; then
    rbenv rehash
  fi
fi
