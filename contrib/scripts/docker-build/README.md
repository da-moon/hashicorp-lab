# docker-build

the script in this directory helps with builds/tags/pushes docker images as part of ci/cd process; e.g github-actions or gitlab-ci
	- checks for missing build requirements.
	- encapsulates complex logic to read and build based on tags.
	- simplifies build/push cycle.

## usage

[![asciicast](https://asciinema.org/a/.svg)](https://asciinema.org/a/)

## considerations

- running `docker-build` script with `--help` flag would show help and optional arguments it accepts.
- in case you want to build image with a specific tag, create a `.tags.ini` file right next to `Dockerfile` and put tags line by line. for example, look at [`docker/levant/.tags.ini`](../../../docker/levant/.tags.ini)
- if `docker-build` script is executed with `--push` flag, it would delete all present docker images on host before pushing.
- to narrow recursive search scope of `docker-build` script, invoke it with `--root-dir` flag.
