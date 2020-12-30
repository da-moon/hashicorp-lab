# vagrant-cloud-lab

## overview

## usage

- ngrok setup 

[![asciicast](https://asciinema.org/a/horu1FfD4ixrz3aqhNRo3pB9q.svg)](https://asciinema.org/a/horu1FfD4ixrz3aqhNRo3pB9q)

- launch containers

```bash
make -j$(nproc) vault-containers
```

- run ansible

```bash
make vault
```

- cleanup and remove containers

```bash
make -j$(nproc) vault-clean
```