FROM debian:jessie
MAINTAINER Patrick Sodré <sodre@zeroae.co>

ENV \
    AP_SERVICE_DIR="/container/service" \
    AP_STATE_DIR="/container/run/state" \
    CONTAINERPILOT="file:///etc/containerpilot.json"

ADD file /container/file
ADD tool /container/tool

ADD build.sh /container/build.sh
RUN /container/build.sh

ADD service-available /container/service-available
RUN /container/tool/ap-service-add :containerpilot

VOLUME [ "/var/lib/consul", "/container/run/state" ]

CMD ["containerpilot", "ap-spin"]
