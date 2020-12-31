# batch-job

## overview

`batch` job are short lived jobs that behave the same as cronjobs.
one can replace `crontab` or `systemd-timer` with a nomad batch job as long 
as you do not need the job to run on every node in cluster; at the time of writing this document, Nomad does not support `batch-system` jobs.

## usage

the following snippet can be used to deploy the batch job to nomad

```bash
export DC="dc1"; \
levant deploy \
	-var-file=vars.yml \
	batch.nomad
```

## considerations

- `datacenters` directive is populated based on `DC` environment variable
- the sample tasks showcase how to use nomad's `raw_exec` driver to 
	- run an application , i.e `date`
	- run a bash script with control flow statement , i.e `for` loop.
	- run a bash script that has command substitution.
