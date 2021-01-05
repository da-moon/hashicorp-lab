#!/usr/bin/env bash
set -o errtrace
set -o functrace
set -o errexit
set -o nounset
set -o pipefail
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
if [ -n "$(command -v apt-get)" ]; then
  export DEBIAN_FRONTEND=noninteractive
  echo 'deb http://deb.debian.org/debian/ buster contrib non-free' | sudo tee /etc/apt/sources.list.d/debian-extras.list > /dev/null
  sudo apt-get update -qq > /dev/null 2>&1
  sudo apt-get install -yqq \
   git pandoc librsvg2-bin pdftk poppler-utils \
   texmaker texlive-xetex texlive-fonts-recommended \
   texlive-fonts-extra texlive-latex-extra ttf-mscorefonts-installer > /dev/null 2>&1
fi
[ -r /opt/pandoc-latex-template ] ||  sudo git clone \
    https://github.com/Wandmalfarbe/pandoc-latex-template /opt/pandoc-latex-template > /dev/null 2>&1
sudo chown "$USER:$USER" /opt/pandoc-latex-template -R
grep -q "pandoc" ~/.bashrc || echo "git -C /opt/pandoc-latex-template pull > /dev/null 2>&1" | tee -a ~/.bashrc > /dev/null
[ -L /usr/share/pandoc/data/templates/eisvogel.latex ] || sudo ln \
  -s /opt/pandoc-latex-template/eisvogel.tex \
  /usr/share/pandoc/data/templates/eisvogel.latex