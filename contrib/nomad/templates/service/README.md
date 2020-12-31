
# service-job

## overview

this template shows how to have a nomad service job with docker driver.

## usage

the following snippet can be used to deploy the render template and deploy service job to nomad

```bash
DC="dc1"; \
levant deploy \
  -var-file=vars.yml \
  -canary-auto-promote=20 \
  service.nomad
```

## considerations

- the service job run `fjolsvin/http-echo-rs` docker image. this is a small webserver, written in rust that echos what you start it with.
- I have tried to use control statements and functions to showcase power of Levant's templating; refer to comments in [`vars.yml`](vars.yml) 
- docker `volumes` and `args` show how to loop over an array
- this job has canary deploy policy.
- `network` stanza is set in a way to have access to consul dns and docker bridge dns. you can access another service through `http://<service_name>:<port>` ( you can omit service.consul from domain name)
- be careful with special characters in names. 
  - `port` names cannot have hyphens.
  - Service name must be valid per `RFC 1123` and can contain only `alphanumeric characters` or `hyphens`.
- canary deploys:
  - when doing `canary` deploys, make sure `update` stanza is on `job` level. 
  - only if `count` is greater than one,and after the first deploy , add `-canary-auto-promote=10` flag so that levant watcher would auto-promote the job. 
  - it is good practice to make sure value passed to `-canary-auto-promote` is larger that `update` stanza's `min_healthy_time` directive.

