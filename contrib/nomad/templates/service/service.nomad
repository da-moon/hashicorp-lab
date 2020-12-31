job "[[.service.name]]" {
  [[  if .service.datacenters ]]datacenters =  [ [[range $index, $value := .service.datacenters ]][[if ne $index 0]],[[end]]"[[$value]]"[[end]] ][[ else ]]datacenters = [ "[[ or (env "DC") "dc1" ]]" ][[ end ]][[  if .service.namespace ]]
  namespace = "[[.service.namespace]]" [[ else if (env "NOMAD_NAMESPACE") ]]namespace = [ "[[ (env "NOMAD_NAMESPACE")  ]]" ][[ end ]]
  type="service" 
  [[ if .service.canary ]]# [NOTE] => canary deploy  
  update {
    auto_revert       = true
    max_parallel      = 1 
    canary            = 1 
    progress_deadline = "0"
    stagger = "2m"
    healthy_deadline  = "1m" 
    min_healthy_time  = "15s"
  }[[ else ]] # [NOTE] => rolling release
  update {
    max_parallel = 1
    min_healthy_time = "15s"
    healthy_deadline = "1m"
    auto_revert = true
    canary = 0
  }[[ end ]]
  migrate {
    max_parallel = 1
    health_check = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "5m"
  }
  group "[[.service.name]]" {
    count = "[[ or (.service.count) "1" ]]"
    ephemeral_disk {
      size    = "[[ or (.service.disk_size) "300" ]]"
      migrate = true
    }
    restart {
      attempts = 3
      interval = "2m"
      delay    = "15s"
      mode     = "fail"
    }
    # [NOTE] => setting network mode to bridge here causes 
    # container to loose internet access
    network {[[ if .service.port_name ]]
      port  "[[.service.port_name]]" {}[[ end ]]
      dns {
        servers =  [
          "172.17.0.1",
          "${attr.unique.network.ip-address}",
        ]
        searches= ["service.consul"]
      }
    }
    task "[[.service.name]]" {
      driver = "docker"
      config {
        image = "[[.docker.image_name]][[ if .docker.tag ]]:[[.docker.tag]][[end]]"[[ if .docker.volumes ]]
        volumes =  [ [[range $index, $value := .docker.volumes]][[if ne $index 0]],[[end]]"[[$value]]"[[end]] ][[ end ]][[ if .docker.args]]
        args =  [ [[range $index, $value := .docker.args]][[if ne $index 0]],[[end]]"[[$value]]"[[end]] ][[ end ]][[ if .service.port_name ]]
        ports=["[[.service.port_name]]"][[ end ]]
      }
      resources {
        cpu  = "[[.service.cpu]]"
        memory  = "[[.service.ram]]"
      }
      logs {
        max_files     = "[[ or (.service.logs_max_files) "3" ]]"
        max_file_size = "[[ or (.service.logs_max_file_sizes) "1" ]]"
      }
      kill_timeout = "3s"
    }
    service {
      name = "[[.service.name]]-svc"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.[[.service.name]]-svc.rule=Host(`[[.service.name]].[[.service.domain]]`)",
        "traefik.http.routers.[[.service.name]]-svc.entrypoints=web,websecure",
        "traefik.http.services.[[.service.name]]-svc.loadbalancer.sticky=true",
        "traefik.http.services.[[.service.name]]-svc.loadbalancer.sticky.cookie.httponly=true",
        "traefik.http.services.[[.service.name]]-svc.loadbalancer.sticky.cookie.samesite=strict",
        "traefik.http.services.[[.service.name]]-svc.loadbalancer.sticky.cookie.secure=true",
      ][[ if .service.port_name ]]
      port = "[[.service.port_name]]"
      [[ if .service.health_check_path]]check {
        path     = "[[.service.health_check_path]]"
        type     = "http"
        interval = "10s"
        timeout  = "2s"
      }[[ end ]][[ end ]]
    }
  }
}
