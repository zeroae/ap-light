#!/bin/bash -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Consul and ContainerPilot
CONSUL_VERSION=0.7.3-rfc2782
CONSUL_URL_BASE=https://github.com/zeroae/consul/releases/download
CONSUL_CHECKSUM=9c13de0de9697fc646899cbf58d39d13b061c803c2d306c321281246890d1576

CONTAINERPILOT_VERSION=2.7.0
CONTAINERPILOT_SHA1=687f7d83e031be7f497ffa94b234251270aee75b
CONTAINERPILOT_FORK=joyent
CONTAINERPILOT_URL_BASE="https://github.com/${CONTAINERPILOT_FORK}/containerpilot/releases/download"

function download_consul()
{
    archive=consul_${CONSUL_VERSION}_linux_amd64.zip
    curl --retry 7 --fail -Lso /tmp/${archive} \
        ${CONSUL_URL_BASE}/v${CONSUL_VERSION}/${archive}
    echo "${CONSUL_CHECKSUM}  /tmp/${archive}" | sha256sum -c

    cd /container/tool
    unzip /tmp/${archive}
    chmod +x /container/tool/consul
    rm /tmp/${archive}

    mkdir -p /var/lib/consul
    mkdir -p /etc/consul.d

    mv $DIR/assets/consul.json.cptmpl /etc/consul.d/00_base.json.cptmpl

    ln -s /container/tool/consul /sbin
}

function download_containerpilot()
{
    archive=containerpilot-${CONTAINERPILOT_VERSION}.tar.gz
    curl --retry 7 --fail -Lso /tmp/${archive} \
        ${CONTAINERPILOT_URL_BASE}/${CONTAINERPILOT_VERSION}/${archive}
    echo "${CONTAINERPILOT_SHA1}  /tmp/${archive}" | sha1sum -c

    tar zxf /tmp/${archive} -C /container/tool
    chmod +x /container/tool/containerpilot
    rm /tmp/${archive}

    mkdir /etc/containerpilot.d

    mv $DIR/assets/containerpilot-runonce /container/tool
    mv $DIR/assets/containerpilot-render /container/tool
    mv $DIR/assets/containerpilot.json /etc

    ln -s /container/tool/containerpilot* /sbin
}

download_consul
download_containerpilot

exit 0
