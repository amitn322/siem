FROM alpine:3.8

LABEL maintainer "https://github.com/blacktop"

RUN apk add --no-cache openjdk8-jre su-exec

ENV VERSION 6.5.4
ENV DOWNLOAD_URL "https://artifacts.elastic.co/downloads/elasticsearch"
ENV ES_TARBAL "${DOWNLOAD_URL}/elasticsearch-oss-${VERSION}.tar.gz"
ENV ES_TARBALL_ASC "${DOWNLOAD_URL}/elasticsearch-oss-${VERSION}.tar.gz.asc"
ENV EXPECTED_SHA_URL "${DOWNLOAD_URL}/elasticsearch-oss-${VERSION}.tar.gz.sha512"
ENV ES_TARBALL_SHA "1835aa2862104d328deb5bfcdbbab5d121cd8dff883b7f56f14cc4dadb88c7560b688ac21fb51e0d086b6ed07e0345f26de91c2887253b40abf23c4d5e37e197"
ENV GPG_KEY "46095ACC8548582C1A2699A9D27D666CD88E42B4"
# https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-6.3.0.zip
RUN apk add --no-cache bash
RUN apk add --no-cache -t .build-deps wget ca-certificates gnupg openssl \
  && set -ex \
  && cd /tmp \
  && echo "===> Install Elasticsearch..." \
  && wget --progress=bar:force -O elasticsearch.tar.gz "$ES_TARBAL"; \
  if [ "$ES_TARBALL_SHA" ]; then \
  echo "$ES_TARBALL_SHA *elasticsearch.tar.gz" | sha512sum -c -; \
  fi; \
  if [ "$ES_TARBALL_ASC" ]; then \
  wget --progress=bar:force -O elasticsearch.tar.gz.asc "$ES_TARBALL_ASC"; \
#  export GNUPGHOME="$(mktemp -d)"; \
#  ( gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
#  || gpg --keyserver pgp.mit.edu --recv-keys "$GPG_KEY" \
#  || gpg --keyserver keyserver.pgp.com --recv-keys "$GPG_KEY" ); \
#  gpg --batch --verify elasticsearch.tar.gz.asc elasticsearch.tar.gz; \
  rm -rf "$GNUPGHOME" elasticsearch.tar.gz.asc || true; \
  fi; \
  tar -xf elasticsearch.tar.gz \
  && ls -lah \
  && mv elasticsearch-$VERSION /usr/share/elasticsearch \
  && adduser -D -h /usr/share/elasticsearch elasticsearch \
  && echo "===> Creating Elasticsearch Paths..." \
  && for path in \
  /usr/share/elasticsearch/data \
  /usr/share/elasticsearch/logs \
  /usr/share/elasticsearch/config \
  /usr/share/elasticsearch/config/scripts \
  /usr/share/elasticsearch/tmp \
  /usr/share/elasticsearch/plugins \
  ; do \
  mkdir -p "$path"; \
  chown -R elasticsearch:elasticsearch "$path"; \
  done \
  && rm -rf /tmp/* \
  && apk del --purge .build-deps

COPY elasticsearch/elasticsearch.yml /usr/share/elasticsearch/config
COPY elasticsearch/log4j2.properties /usr/share/elasticsearch/config
COPY elasticsearch/logrotate /etc/logrotate.d/elasticsearch
COPY elasticsearch/elastic-entrypoint.sh /
RUN ["chmod", "+x", "/elastic-entrypoint.sh"]
COPY elasticsearch/docker-healthcheck /usr/local/bin/

WORKDIR /usr/share/elasticsearch

ENV PATH /usr/share/elasticsearch/bin:$PATH
ENV ES_TMPDIR /usr/share/elasticsearch/tmp

VOLUME ["/usr/share/elasticsearch/data"]

EXPOSE 9200 9300
ENTRYPOINT ["/bin/bash", "/elastic-entrypoint.sh"]
#ENTRYPOINT ["/bin/sh"]
CMD ["elasticsearch"]

# HEALTHCHECK CMD ["docker-healthcheck"]