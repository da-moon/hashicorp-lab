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

-  in case your host machine is a remote server (lxd is running on remote), you might want to access api a port like `https://localhost:5678`. use the following snippet on host to redirect all connections to port `5678` to a consul-replicate container

```bash
lxc config device add "consul-replicate" "proxy-consul-replicate" proxy listen=tcp:0.0.0.0:5678 connect=tcp:127.0.0.1:5678
```

remove the proxy with the following snippet :

```bash
lxc config device remove "consul-replicate" "proxy-consul-replicate"
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

- install Consul-replicate

```bash
ansible-playbook \
  -i staging \
  -e vault_password_file=~/.vault_pass.txt \
  --vault-password-file ~/.vault_pass.txt \
  --limit staging \
  --tags 02-install-consul-replicate \
  site.yml
```


- configure Consul replicate

```bash
ansible-playbook \
  -i staging \
  -e vault_password_file=~/.vault_pass.txt \
  --vault-password-file ~/.vault_pass.txt \
  --limit staging \
  --tags 03-configure-consul-replicate \
  site.yml
```



## Variables


### Installer Variables

- `override_consul_replicate_install` : 
  - when set to 'true' , this variable forces the playbook ignores version check and always downloads consul replicate binary and replaces it in . 
  - default: `OVERRIDE_CONSUL_REPLICATE_INSTALL` environment variable, if environment variable is not present, it would use `false` as default value.
- `consul_replicate_version` : 
  - sets consul-replicate version to be installed. In case this is left blank or undefined, the role would detect the latest non-beta version and download it. 
  - This value __must__ follow semantic versioning , e.g `0.3.0`. 
  - default: `CONSUL_REPLICATE_INSTALL_VERSION` environment variable.

### Cluster Information Variables

- `consul_addr` : 
  - This is the address of the Consul agent. 
  - this variable must be present.
  - default: `CONSUL_HTTP_ADDR` environment variable on ansible host.
- `consul_token` : 
  - This is the ACL token to use when with consul-replicate is connecting to to Consul Cluster . 
  - default : `CONSUL_HTTP_TOKEN` environment variable.
- `consul_namespace` : 
  - sets target consul namespace.
  - default : `CONSUL_NAMESPACE` environment variable.
- `log_level` : 
  - set's consul-replicate log level in config file. 
  - default : `CONSUL_REPLICATE_LOG_LEVEL` environment variable, if environment variable is not present, it would use `ERROR` as default value.

### SSL related Variables

- `ssl_enabled` : 
  - setting this to `true` will add extra directives related to ssl to `ssl` stanza to consul-replicate configuration file. 
  -  defaults : `CONSUL_REPLICATE_SSL_ENABLED` environment variable, if environment variable is not present, it would use `false` as default value. 

- dirctives added to `ssl` stanza when `ssl_enabled` is set to `true`:
  - `ssl_verify` : 
    - corresponds to `verify` directive. 
    - This enables SSL peer verification. 
    - default: `CONSUL_REPLICATE_SSL_VERIFY` environment variable, if environment variable is not present, it would use `false` as default value
  - `ssl_cert` : 
    - corresponds to `cert` directive.
    - This is the path to the consul client certificate public key.
    - default: `CONSUL_REPLICATE_SSL_CERT` environment variable.
  - `ssl_key` : 
    - corresponds to `key` directive.
    - This is the path to the consul client certificate private key.
    - default: `CONSUL_REPLICATE_SSL_KEY` environment variable.
  - `ssl_ca_cert` : 
    - corresponds to `ca_cert` directive.
    - This is the path to the certificate authority to use as a CA.
    - default: `CONSUL_REPLICATE_SSL_CA_CERT` environment variable.
  - `ssl_ca_path` : 
    - corresponds to `ca_path` directive.
    - This is the path to a directory of PEM-encoded CA cert files.
    - default: `CONSUL_REPLICATE_SSL_CA_PATH` environment variable.
  - `ssl_server_name` : 
    - corresponds to `server_name` directive.
    - sets the SNI server name to use for validation.
    - default: `CONSUL_REPLICATE_SSL_SERVER_NAME` environment variable.

### Replication related Variables

- `exclude_sources` : 
  - a comma delinitad string which represents list of keys to exclude if they are found in the prefix.
  - the role deduplicates this list.
  - default: `CONSUL_REPLICATE_EXCLUDE_SOURCES` environment variable.
- `prefix_source` : 
  - source prefix replicate
  - default: `CONSUL_REPLICATE_PREFIX_SOURCE` environment variable.
- `prefix_datacenter` : 
  - source datacenter to replicate
  - default: `CONSUL_REPLICATE_PREFIX_DATACENTER` environment variable.
- `prefix_destination` :  
  - replication target destination
  - default: `CONSUL_REPLICATE_PREFIX_DESTINATION` environment variable.

### Defaults

- `architecture_map` : used to find the architecture value in consul-replicate download url. 
- `ansible_ssh_common_args` : used for disabling strict ssh host checking
- `systemd_unit_directory` : default systemd unit directory. for the sake of differentiating this unit with unit files added through package manger install it defaults to `/usr/lib/systemd/system` 
- `consul_replicate_install_dir` :  default location to put consul-replicate for the sake of 
- `consul_replicate_releases_base_url` : base download url for consul-replicate.
- `consul_replicate_user_home_path` : home directory for consul-replicate system user which is where consul-replicate configuration files are stored. Default to `/etc/consul-replicate`


## Example Variables


```yml
# [ NOTE ] Optional
consul_replicate_version          : "0.3.0"
# [ NOTE ] Optional
override_consul_replicate_install : true
consul_addr                       : "https://consul-server-1:8500"
consul_token                      : "consul-token"
prefix_source                     : "global"
prefix_datacenter                 : "nyc1"
prefix_destination                : "default"
# [ NOTE ] Optional
exclude_sources                   : "foo,foo,bar,baz,,foobar"
# [ NOTE ] All SSL vars are optional
ssl_enabled                       : true
ssl_verify                        : true
ssl_cert                          : "/path/to/client/cert"
ssl_key                           : "/path/to/client/key"
ssl_ca_cert                       : "/path/to/ca"
```
