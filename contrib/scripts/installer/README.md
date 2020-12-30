# installer

## overview

Collection of scripts to install various tools on host os.

## scripts

- [`vagrant`](vagrant) :
  - this script only works with `Debian` based distros.
  - installs [`vagrant-vbguest`](https://github.com/dotless-de/vagrant-vbguest) plugin which is needed to enable synced directories.
  - enables `sudo-less` invocation of `vagrant` command.
  - keep in mind that this script needs `jq`, `wget`,`curl`, `xargs` and `sudo` to work.
- [`virtualbox`](virtualbox)
  - this script is only meant to be ran `debian` based distros.
  - this script installs some dependencies, adds `virtualbox` sources, and installs virtualbox.
  - Virtualbox is not gauranteed to work with other kernels such as `liquorix` or `zen`. You must remove all non-generic kernels before installing virtualbox.
- [`ngrok`](ngrok) :
  - installs [ngrok](https://ngrok.com/) on `Linux` machines.
  - This can be used for setting up reverse ssh into your vagrant box; e.g Use vscode's [`remote-ssh`](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension
    to directly ssh into a vagrant box that is running on a remote cloud box. This is particularly useful when your local machine is not powerful enough and you have a remote box with enough resources.
  - this script sets up systemd units and config files. make sure that you have your ngrok token prepared or set `NGROK_TOKEN` environment variable in your shell. If the environment variable is not present, the script would ask for it.
  - after running the script, look into 
- [`vscode`](vscode)
  - this script is only meant to be ran `debian` based distros.
  - this script adds `vscode` sources and installs Visual Studio Code.
- [`vscode-extensions`](vscode-extensions)
  - this script installs some useful extensions such as [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)
- [`openstack`](openstack) : 
  - install openstack python client
  - installs `neutron` component.
