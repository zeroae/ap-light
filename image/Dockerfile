FROM debian:jessie
MAINTAINER Patrick Sodré <sodre@zeroae.co>

ADD file /container/file
ADD tool /container/tool

ADD build.sh /container/build.sh
RUN /container/build.sh

ADD service-available /container/service-available
RUN /container/tool/ap-add-service :containerpilot

ENV CONTAINERPILOT="file:///etc/containerpilot.json"
VOLUME [ "/var/lib/consul" ]

CMD ["containerpilot", "ap-spin"]
