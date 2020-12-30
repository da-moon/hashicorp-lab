# vagrant

## overview

the artifacts in this directory provision vagrant virtual machine,

- [`bin`](bin/README.md) : collection of helper utilities which will be copied to `/usr/local/bin` of vagrant box
- [`docker`](docker/README.md) : docker image that backs the vagrant box when launched with `--provider=docker`.
- [`provision`](provision/README.md) : collection of provisioner scripts for the vagrant box.
