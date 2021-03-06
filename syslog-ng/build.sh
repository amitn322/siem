#!/bin/sh

set -e

#echo "http://mirror.yandex.ru/mirrors/alpine/v3.4/main/"       > /etc/apk/repositories

export SYSLOG_VERSION=3.19.1

export DOWNLOAD_URL="https://github.com/balabit/syslog-ng/releases/download/syslog-ng-${SYSLOG_VERSION}/syslog-ng-${SYSLOG_VERSION}.tar.gz"

apk update

apk add libressl-dev
apk add openjdk8 
apk add glib pcre eventlog openssl #openssl-dev
apk add curl alpine-sdk glib-dev pcre-dev eventlog-dev
apk add libmaxminddb libmaxminddb-dev json-c json-c-dev curl-dev gradle
export PATH=/usr/lib/jvm/java-1.8-openjdk/bin/:$PATH
cd /tmp
curl -L "${DOWNLOAD_URL}" > "syslog-ng-${SYSLOG_VERSION}.tar.gz"
tar zxf "syslog-ng-${SYSLOG_VERSION}.tar.gz"
cd "syslog-ng-${SYSLOG_VERSION}"
#./configure --prefix=/usr
./configure --enable-http --enable-java --enable-java-modules  --enable-geoip2 --prefix=/ --sysconfdir=/etc/syslog-ng/ --enable-format-json --enable-json
make
make install
cd ..
rm -rf "syslog-ng-${SYSLOG_VERSION}" "syslog-ng-${SYSLOG_VERSION}.tar.gz"

apk del curl alpine-sdk glib-dev pcre-dev eventlog-dev libmaxminddb-dev json-c-dev curl-dev libressl-dev

