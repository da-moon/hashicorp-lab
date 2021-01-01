# vagrant-cloud-lab

## overview

## usage

### [`vault lab`](playbooks/vault/README.md)

[![asciicast](https://asciinema.org/a/BzL3tXTkGL8xqSF5UiqWyZajB.svg)](https://asciinema.org/a/BzL3tXTkGL8xqSF5UiqWyZajB)

- setup backend containers : `make -j$(nproc) vault-containers`
- provision the containers : `make vault`
- in case your host is the Vagrant box run `source contrib/env/vault.env` to set your shell's environment variables for interacting with Vault cluster
- in case your vagrant box is running on a remote server and you want to bind local machine's port 8200 to port 8200 of the box so that you can access Vault server API (e.g access UI )through 'https://localhost:8200' :
  - instruct lxd to map box's port 8200 to a `vault-1` container's port 8200  : `lxc config device add "vault-1" "proxy-vault-1" proxy listen=tcp:0.0.0.0:8200 connect=tcp:127.0.0.1:8200`
  - setup your local machine's ssh config and add `LocalForward 127.0.0.1:8200 127.0.0.1:8200` to the target host entry
- teardown : `make -j$(nproc) vault-clean`


### [`nomad lab`](playbooks/nomad/README.md)

[![asciicast](https://asciinema.org/a/ZawavjyMOMaYNBASzxrUPTtl7.svg)](https://asciinema.org/a/ZawavjyMOMaYNBASzxrUPTtl7)

- setup backend containers : `make -j$(nproc) nomad-containers`
- provision the containers : `make nomad`
- in case your host is the Vagrant box run `source contrib/env/nomad.env` to set your shell's environment variables for interacting with Nomad cluster.
- in case your vagrant box is running on a remote server and you want to bind local machine's port 4646 to port 4646 of the box so that you can access Nomad server API (e.g access UI ) through 'https://localhost:4646' :
  - instruct lxd to map box's port 4646 to a `nomad-server-1` container's port 4646  : `lxc config device add "nomad-server-1" "proxy-nomad-server-1" proxy listen=tcp:0.0.0.0:4646 connect=tcp:127.0.0.1:4646`
  - setup your local machine's ssh config and add `LocalForward 127.0.0.1:4646 127.0.0.1:4646` to the target host entry
- teardown : `make -j$(nproc) nomad-clean`


### misc

- [`ngrok`](https://ngrok.com) setup

[![asciicast](https://asciinema.org/a/horu1FfD4ixrz3aqhNRo3pB9q.svg)](https://asciinema.org/a/horu1FfD4ixrz3aqhNRo3pB9q)


## Todo

- [x] Vault Lab
- [ ] Consul Lab
- [x] Nomad Lab