job "[[.service.name]]-curl" {
  [[  if .service.datacenters ]]datacenters =  [ [[range $index, $value := .service.datacenters ]][[if ne $index 0]],[[end]]"[[$value]]"[[end]] ][[ else ]]datacenters = [ "[[ or (env "DC") "dc1" ]]" ][[ end ]][[  if .service.namespace ]]
  namespace = "[[.service.namespace]]" [[ else if (env "NOMAD_NAMESPACE") ]]namespace = [ "[[ (env "NOMAD_NAMESPACE")  ]]" ][[ end ]]
  type = "batch"[[  if .service.cron ]]
  periodic {
    # [NOTE] => run every minute
    cron  = "[[ .service.cron]]"
    prohibit_overlap = true
  }[[end]]
  group "[[.service.name]]-curl" {
    count = 1
    network {
      dns {
        servers =  [
          "172.17.0.1",
          "${attr.unique.network.ip-address}",
        ]
        searches= ["service.consul"]
      }
    }[[ with $service := $.service ]][[ with $curl := $.curl ]][[range $index, $value := $curl.urls ]]
    task "[[$service.name]]-curl-[[$index]]" {
      driver = "docker"
      config {
        image = "curlimages/curl:[[or ($curl.image_tag) "7.73.0" ]]"
        args = [
          "-s",
          "-D",
          "-",
          "-o",
          "/dev/stderr",
          "[[$value]]"
        ]
      }
    }[[end]][[ end ]][[ end ]]
  }
}
