# Changelog

## 0.5.0
    - Runonce now runs the scripts in the correct order.
    - Added manta library to service-available.
    - Consul agent waits until there is a leader before continuing.

## 0.4.0
    - Added configuration options for CONSUL_{DOMAIN,DATACENTER,ACL_{DATACENTER,TOKEN}}.
    - Execute `runonce.sh` in the service directory before preStart.
    - Renamed tools to follow the ap-{tool-name} pattern.
    - Added AP_{STATE,SERVICE}_DIR environment variables.

## 0.3.0
    - Added consul-agent as an available-service. Use "ap-add-service :consul-agent" to add it to your image.
    - Fixed bug where preStart was not being called.

## 0.2.0
    - Added ap-spin script that just spins, this is the default containerpilot process.
    - Users should use "coprocess" to spin up the individual services.

## 0.1.0
    - The install-service script copies contents of my-service/[consul,containerpilot].d into /etc/[consul,containerpilot].d

## 0.0.1
    - Initial release

