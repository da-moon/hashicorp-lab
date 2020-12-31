# nomad-lab

Cloud agnostic Ansible playbooks used to deploy nomad cluster.
At this point, playbooks in this directory setup a barebone Nomad cluster :

- No Vault integration
- No Consul integration
- No ACL

## Snippets

- check connectivity

```bash
ansible -i staging -m ping all -vvv
```

- Generate a random password to encrypt data with `ansible-vault` and store it in `~/.vault_pass.txt`.This file already exists in the Vagrant box so there is no need to run it if your Ansible controller is the Vagrant box.

```bash
echo -n "$(dd if=/dev/urandom bs=64 count=1 status=none | base64)" | tee ~/.vault_pass.txt
```

- in case your host machine is a remote server (lxd is running on remote), use the following snippet on host to redirect all connections to port `4646` to a nomad server's container

```bash
sudo iptables -t nat -A PREROUTING -i $(ip link | awk -F: '$0 !~ "lo|vir|wl|lxd|docker|^[^0-9]"{print $2;getline}') -p tcp --dport 4646 -j DNAT --to "$(lxc list --format json | jq -r '.[] | select((.name | contains ("server")) and (.status=="Running")).state.network.eth0.addresses|.[] | select(.family=="inet").address' | head -n 1):4646"
```

- Setup Ansible Controller Software

```bash
ansible-playbook \
  -i staging \
  --tags 01-ansible-controller \
  site.yml
```

- Setup base dependencies for all inventory hosts

```bash
ansible-playbook \
  -i staging \
  --tags 02-install-prerequisites \
  site.yml
```

- install Nomad

```bash
ansible-playbook \
  -i staging \
  --limit staging-servers \
  --tags 03-install-nomad \
  site.yml
```

- generate certificates for Nomad Server

```bash
ansible-playbook \
  -i staging \
  -e vault_password_file=~/.vault_pass.txt \
  --vault-password-file ~/.vault_pass.txt \
  --limit staging-servers \
  --tags 04-nomad-certificates \
  site.yml
```

- configure Nomad Server

```bash
ansible-playbook \
  -i staging \
  -e vault_password_file=~/.vault_pass.txt \
  --vault-password-file ~/.vault_pass.txt \
  --limit staging-servers \
  --tags 05-configure-nomad-server \
  site.yml
```

- configure Nomad Clients

```bash
ansible-playbook \
  -i staging \
  -e vault_password_file=~/.vault_pass.txt \
  --vault-password-file ~/.vault_pass.txt \
  --limit staging-clients \
  --tags 06-configure-nomad-client \
  site.yml
```

## TODO

- [] bootstrap acl policy