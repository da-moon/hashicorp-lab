# vagrant-cloud-lab

## overview

to help developers get started instantly, on a shared environment , we have prepared a `Vagrantfile` with multiple providers

- `docker` : sets up and provisions a docker based work environment. useful for quick developments. this provider does not support running `lxd` or `docker` containers
- `virtualbox` : sets up and provisions a virtualbox based work environment. 

## usage

[![asciicast](https://asciinema.org/a/2ZBLsj9mf5M4JTfb2NOGJnKpu.svg)](https://asciinema.org/a/2ZBLsj9mf5M4JTfb2NOGJnKpu)

> `NOTE` : I have fixed the issue with running docker in lxd in Virtualbox that was shown in the video.

the boxes have the following set of common overridable configuration values : 

- default value for box name is set to parent directory of `Vagrantfile`, i.e `vagrant-cloud-lab`. you can ovveride this value by setting `VAGRANT_MACHINE_NAME` environment variable
- On providers that allow limiting box's CPU and RAM, default value for RAM is set to `4GB`
  and for CPU is set to `4` cores. you can ovveride RAM and CPU limits by setting `MEMORY_LIMIT` and `CORE_LIMIT` environment variables.
  
make sure you have installed [`vagrant`](https://www.vagrantup.com/downloads). 
For convenience, I have prepared an installer script for debian based distros

```bash
bash contrib/scripts/installer/vagrant
```

the following is a list of pointers on how to use vagrant

- start the vm by running `vagrant up`
- you can reload vm configuration by running `vagrant reload`
- you can generate and store ssh config by running `vagrant ssh-config >> ~/.ssh/config`. 
  - after generating and storing ssh config, you can access the box by running `ssh vagrant-cloud-lab`. 
  - you can also use this box with [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview). In `VScode`, press `ctrl+shift+p` , search for and choose `Remote-SSH: Connect to host...` , choose `vagrant-cloud-lab` host.
  - this box has [`spacevim`](https://spacevim.org/) installed so you can work in it right from the terminal
- `vagrant ssh` can also be used for ssh'ing into the box.
- your workspace is at `/vagrant` inside the box.
- once you are done, shutdown vm by running `vagrant halt`
- you can provision the vm (run provisioner scripts) again (in case of faulty provisioning or to update hashicorp tools) by running `vagrant provision`
- by default , `config.vm.network "forwarded_port"` directive is used for port forwarding. there are some example ports forwarded in the `Vagrantfile`, feel free to change it as you see fit. 
  - Keep in mind that you must run `vagrant reload` after changing/adding/removing forwarded ports to see changes reflected.
  - you can use `vagrant ssh -- -L 8080:localhost:80` to forward ports without running `vagrant reload`. In the example snippet, port `80` on __box__ is forwarded to port `8080` on __host__ .


## providers

a common set of tools are installed on every provider. look into [contrib/vagrant/provision](contrib/vagrant/provision/README.md) readme file for more information.

### virtualbox

- Default provider has been set to `virtualbox`. you can override this by setting `VAGRANT_DEFAULT_PROVIDER` environment variable.
- base box is [`generic/debian10`](https://app.vagrantup.com/generic/boxes/debian10). Other debian buster boxes had some issues which made them not suitable for us.
- nested vm support has been enabled
- make sure that you have already installed [`virtualbox`](https://www.virtualbox.org/wiki/Downloads) on your system. 
  For convenience, we have prepared an installer script for debian based host machines.

```bash
bash contrib/scripts/installer/virtualbox
```

> Virtualbox is not gauranteed to work with other kernels such as `liquorix` or `zen`.
  you must remove all non-generic kernels beforeinstalling virtualbox.

### docker

`docker` provider can be a useful alternative to `virtual` box provider. 
you can launch it with `vagrant up --provider=docker`. Keep the following in mind before using docker provider :

- due to it's containerized nature, `lxd` and `docker` are not installed in this container; so as an example, you won't be able to build docker images in it
- Vagrant's built-in `synced_folder` directive , which is used to push your work directory into the container does not support two-way sync. To fix this issue, I am using docker volume mounts. 
  Keep in mind that after starting the box (`vagrant [up,reload,resume]`) , all direcotries but `.git` and `.vagrant` will be owned by `vagrant` user inside the container. the ownership will go back to user after stopping the box (`vagrant [destroy,halt,suspend]`)
- the base docker image for this container is located at [`contrib/vagrant/docker`](contrib/vagrant/docker/README.md)
