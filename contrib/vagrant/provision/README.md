# provision

## overview

the scripts here provision the vagrant box

- `shared` : scripts that provision all vagrant providers
- `virtualbox` : virtualbox specific provisioner script.

## scripts

- [x] [`init`](init.sh) : installs some common dependencies and updates debian
- [x] [`node`](node.sh) : installs nodejs (`v.12`) and yarn
- [x] [`python`](python.sh) : installs `python` and `python3` and `poetry`.
- [x] [`rbenv`](rbenv.sh) : installs [`rbenv`](https://github.com/rbenv/rbenv) and ruby `2.7.2`
- [x] [`goenv`](goenv.sh) : installs [`goenv`](https://github.com/syndbg/goenv) and go `1.15.5`
- [x] [`levant`](levant.sh) : builds and installs latest version of levant from source.
- [x] [`hashicorp`](hashicorp.sh) : installs latest version of all hashicorp products.
- [x] [`openstack`](openstack.sh) :  installs `openstack` client with `neutron` component
- [x] [`spacevim`](spacevim.sh) : installs `vim`, `neovim`,`spacevim` and configures spacevim for `vagrant` and `root` users.
- [x] [`ripgrep`](ripgrep.sh) : installs latest version of [`ripgrep`](https://github.com/BurntSushi/ripgrep)
- [x] [`lxd`:](lxd) installs `snapd` package and then installs `core` and `lxd` snap packages.it also adds vagrant user to lxd group. LXD accessible on host through LXC; host port is `8443` and password is `vagrant`.
- [x] [`docker`](docker.sh) : installs docker/docker-compose and adds `vagrant` user to docker group
