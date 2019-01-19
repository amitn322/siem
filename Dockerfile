FROM alpine:3.8

ADD ./build.sh /build.sh

RUN /build.sh

ADD ./syslog-ng.conf /etc/syslog-ng/syslog-ng.conf

VOLUME ["/var/log/syslog-ng", "/var/run/syslog-ng"]

#EXPOSE 514/tcp 514/udp

ENTRYPOINT ["/sbin/syslog-ng", "-F", "-f", "/etc/syslog-ng/syslog-ng.conf"]
