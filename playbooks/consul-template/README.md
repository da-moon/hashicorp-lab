# vault-lab

## Overview

Cloud agnostic Ansible playbooks used to deploy vault cluster backed by raft storage engine in HA mode. 

## Features

- Generate certificates with `cfssl` per remote server and encrypt them with `ansible-vault` 
- Generate and encrypt and store gossip encryption key for vault cluster
- Bootstrap and unseal the cluster using Shamir secret sharing without relying on any cloud specific KMS provider or transit secrets engine. 
- No need for a Consul cluster. The configuration uses Vault's new raft storage engine, so the cluster is not dependant on any other service.

## Snippets

- check connectivity

```bash
ansible -i staging -m ping all -vvv
```

-  in case your host machine is a remote server (lxd is running on remote), you might want to access api a port like `https://localhost:5678`. use the following snippet on host to redirect all connections to port `5678` to a consul-template container

```bash
lxc config device add "consul-template" "proxy-consul-template" proxy listen=tcp:0.0.0.0:5678 connect=tcp:127.0.0.1:5678
```

remove the proxy with the following snippet :

```bash
lxc config device remove "consul-template" "proxy-consul-template"
```

- Setup base dependencies for all inventory hosts

```bash
ansible-playbook \
  -i staging \
  -e vault_password_file=~/.vault_pass.txt \
  --vault-password-file ~/.vault_pass.txt \
  --tags 01-install-prerequisites \
  site.yml
```

- install Consul-template

```bash
ansible-playbook \
  -i staging \
  -e vault_password_file=~/.vault_pass.txt \
  --vault-password-file ~/.vault_pass.txt \
  --limit staging \
  --tags 02-install-consul-template \
  site.yml
```


- configure Consul Template

```bash
ansible-playbook \
  -i staging \
  -e vault_password_file=~/.vault_pass.txt \
  --vault-password-file ~/.vault_pass.txt \
  --limit staging \
  --tags 03-configure-consul-template \
  site.yml
```

