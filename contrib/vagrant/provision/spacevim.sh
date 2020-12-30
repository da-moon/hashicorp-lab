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
  sudo apt-get update -qq >/dev/null 2>&1
  sudo apt-get -yqq install neovim python-neovim \
    python3-neovim vim-gtk >/dev/null 2>&1
fi

curl -sLf https://spacevim.org/install.sh | bash > /dev/null 2>&1
curl -sLf https://spacevim.org/install.sh | sudo -H -s -u root bash -s > /dev/null 2>&1
sudo python3 -m pip install --upgrade pynvim notedown
sudo yarn global add --silent remark remark-cli remark-stringify remark-frontmatter wcwidth >/dev/null 2>&1
mkdir -p ~/.SpaceVim.d/
cat << EOF | tee ~/.SpaceVim.d/init.toml > /dev/null
[[custom_plugins]]
    repo = "chr4/nginx.vim"
    merged = false

[[custom_plugins]]
    repo = "hashivim/vim-hashicorp-tools"
    merged = false

[[custom_plugins]]
  repo = "jvirtanen/vim-hcl"
  merged = false

[[layers]]
name = 'autocomplete'
auto_completion_return_key_behavior = "complete"
auto_completion_tab_key_behavior = "smart"

[[layers]]
name = 'shell'
default_position = 'top'
default_height = 30

[[layers]]
  name = "colorscheme"

[[layers]]
  name = "tools"

[[layers]]
  # [REF] => https://spacevim.org/layers/format/
  name = "format"
  format_on_save = true

[[layers]]
  # [REF] => https://spacevim.org/layers/ui/
  name = "ui"

[[layers]]
  # [REF] => https://spacevim.org/layers/git/
  name = "git"

[[layers]]
  # [REF] => https://spacevim.org/layers/github/
  name = "github"

[[layers]]
  # [REF] => https://spacevim.org/layers/sudo/
  name = "sudo"

[[layers]]
  # [REF] => https://spacevim.org/layers/lang/sh/
  name = "lang#sh"

[[layers]]
  name = "lang#toml"

[[layers]]
  name = "lang#xml"

[[layers]]
  name = "lang#WebAssembly"

[[layers]]
  name = "lang#vue"

[[layers]]
  # [REF] => https://spacevim.org/layers/lang/vim/
  name = "lang#vim"

[[layers]]
  # [REF] => https://spacevim.org/layers/lang/lua/
  name = "lang#lua"

[[layers]]
  name = "lang#dockerfile"

[[layers]]
  # [REF] => https://spacevim.org/layers/lang/gosu/
  name = "lang#gosu"

# sudo yarn global add --prefix /usr/local remark remark-cli remark-stringify remark-frontmatter wcwidth 
[[layers]]
  name = "lang#markdown"

## sudo yarn global add --prefix /usr/local typescript
#[[layers]]
#  # [REF] => https://spacevim.org/layers/lang/typescript/
#  name = "lang#typescript"

# go get -u github.com/jstemmer/gotags
[[layers]]
  name = "lang#go"

[[layers]]
  # [REF] => https://spacevim.org/layers/lang/c/
  name = "lang#c"
  clang_executable = "/usr/bin/clang"
  clang_flag = ['-I/user/include']
  [layer.clang_std]
    c = "c11"
    cpp = "c++1z"
    objc = "c11"
    objcpp = "c++1z"

# gem install rubocop
[[layers]]
  # [REF] => https://spacevim.org/layers/lang/ruby/
  name = "lang#ruby"

# python3 -m pip install pylint yapf isort coverage
[[layers]]
  # [REF] => https://spacevim.org/layers/lang/python/
  name = "lang#python"
  python_file_head = [
    '#!/usr/bin/env python',
    '# -*- coding: utf-8 -*-',
    '',
    ''
  ]
  format_on_save = true
  # [NOTE] => can slow things down
  enable_typeinfo = true

# python3 -m pip install notedown
[[layers]]
  # [REF] => https://spacevim.org/layers/lang/ipynb/
  name = "lang#ipynb"

[[layers]]
  # [REF] => https://spacevim.org/layers/core/statusline/
  name = "core#statusline"

[options]
  #colorscheme = "gruvbox"
  colorscheme = "NeoSolarized"
  colorscheme_bg = "dark"
  enable_guicolors = true
  statusline_separator = "arrow"
  statusline_iseparator = "arrow"
  buffer_index_type = 4
  enable_tabline_filetype_icon = true
  enable_statusline_mode = false
  filemanager = "nerdtree"
  # [Start] => Statusline
  # options for statusline
  # Set the statusline separators of statusline, default is "arrow"
  statusline_separator = "arrow"
  # Set the statusline separators of inactive statusline
  statusline_iseparator = "bar"
  # Set SpaceVim buffer index type
  buffer_index_type = 4
  # 0: 1 ➛ ➊
  # 1: 1 ➛ ➀
  # 2: 1 ➛ ⓵
  # 3: 1 ➛ ¹
  # 4: 1 ➛ 1
  # Enable/Disable show mode on statusline
  enable_statusline_mode = true
  # left sections of statusline
  statusline_left_sections = [
    'winnr',
    'major mode',
    'filename',
    'fileformat',
    'minor mode lighters',
    'version control info',
    'search status'
  ]
  # right sections of statusline
  statusline_right_sections = [
    'cursorpos',
    'percentage',
    'input method',
    'date',
    'time'
  ]
  # [END] => Statusline
EOF
sudo mkdir -p "/root/.SpaceVim.d"
sudo cp "/home/${DEFAULT_USER}/.SpaceVim.d/init.toml" "/root/.SpaceVim.d/init.toml"
