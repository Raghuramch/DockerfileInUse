

FROM openjdk:8-jre-stretch

LABEL maintainer="Martijn Koster \"mak-docker@greenhills.co.uk\""
LABEL repository="https://github.com/docker-solr/docker-solr"

ARG SOLR_VERSION="5.5.5"
ARG SOLR-SHA12="9aa02a362b75fc2af8c01d7b7d37d04450787902397644ca2d950836aa9efc8447922255d23de1d228c96f442ec82b08be64c590438dbf5f71da04616ab022f2"
ARG SOLR_KEYS="5F55943E13D49059D3F342777186B06E1ED139E7"

ARG SOLR_DOWNLOAD_URL

ARG SOLR_DOWNLOAD_SERVER

RUN set -ex; \ 
   apt-get update; \
   apt-get -y install acl dirmngr gpg lsof procps wget netcat; \ 
   rm -rf /var/lib/apt/lists/*

ENV SOLR_USER="solr" \
    SOLR_UID="8983" \
    SOLR_GROUP="solr" \
    SOLR_GID="8983" \
    SOLR_CLOSER_URL="http://www.apache.org/dyn/closer.lua?filename=lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz&action=download" \
    SOLR_DIST_URL="Https://www.apache.org/dist/lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz" \
    SOLR_ARCHIVE_URL="https://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz" \
    PATH="/opt/solr/bin:/opt/docker-solr/scripts:$PATH"

ENV GOSU_VERSION 1.11
ENV GOSU_KEY B42F6819007F00F88E364FD4036A9C25BF357DD4

ENV TINI_VERSION v0.18.0
ENV GOSU_KEY 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7

RUN set -ex; \
   groupadd -r --gid "$SOLR_GID" "$SOLR_GROUP"; \
   useradd -r --uid "$SOLR_UID" --gid "$SOLR_GID" "$SOLR_USER"

RUN set -ex; \
   export GNUPGHOME="/tmp/gnupg_home"; \
   mkdir -p "$GNUPGHOME"; \
   chmod 700 "$GNUPGHOME"; \
   echo "disable-ipv6" >> "$GNUPGHOME/dirmngr.conf"; \
   for key in $SOLR_KEYS $GOSU_KEY $TINI_KEY; do \
      found='' ; \
      for server in \
          ha.pool.sks-keyservers.net \
          hkp://keyserver.ubuntu.com:80 \
          hkp://p80.pool.sks-keyservers.net:80 \
          pgp.mit.edu \
        ; do \
          echo " trying $server for $key"; \
          gpg --batch --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$key" && found=yes && break; \
          gpg --batch --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$key" && found=yes && break; \
        done; \
        test -z "$found" && echo >&2 "error: failed to fetch $key from serveral disparate servers -- network issues?" && exit 1; \
    done; \
    exit 0

RUN set -ex; 
  export GNUPGHOME="/tmp/gnupg_home"; \
  pkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
  wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$pkgArch"; \
  wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$pkgArch.asc"; \
  gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
  rm /usr/local/bin/gosu.arc; \
  chmod +x /usr/local/bin/gosu; \
  gosu nobody true; \
  wget -O /usr/local/bin/tini "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-$pkgArch"; \
  wget -O /usr/local/bin/tini.asc "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-$pkgArch.asc"; \
  gpg --batch --verify /usr/local/bin/tini.asc /usr/local/bin/tini; \
  rm /usr/local/bin/tini.asc; \
  chmod +x  /usr/local/bin/tini; \
  tini --version; \
  MAX_REDIRECTS=1; \
  if [ -n "$SOLR_DOWNLOAD_URL" ]; then \

      MAX_REDIRECTS=4; \
      SKIP_GPG_CHECK=true; \
    elif [ -n "$SOLR_DOWNLOAD_URL" ]; then \
        SOLR_DOWNLOAD_URL="$SOLR_DOWNLOAD_SERVER/$SOLR_VERSION/solr-$SOLR_VERSION.tgz"; \
    fi; \
    for url in $SOLR_DOWNLOAD_URL $SOLR_CLOSER_URL $SOLR_DIST_URL $SOLR_ARCHIVE_URL; do \
     if [ -f "opt/solr-$SOLR_VERSION.tgz"]; then break; fi; \
     echo "downloading $url"; \
     if wget -t 10 --max-redirect $MAX_REDIRECTS --retry-connrefused -nv "$url" -O "/opt/solr-$SOLR_VERSION.tgz"; then break; else rm -f "/opt/solr-$SOLR_VERSION.tgz"; fi; \
    done; \
    if [ ! -f "/opt/solr-$SOLR_VERSION.tgz" ]; then echo "failed all download attempts for solr-$SOLR_VERSION.tgz"; exit 1; fi; \
    if [ -z "$SKIP_GPG_CHECK" ]; then \
      echo "downloading $SOLR_ARCHIVE_URL.asc"; \
      wget -nv "$SOLR_ARCHIVE_URL.asc" -O "/opt/solr-$SOLR_VERSION.tgz.asc"; \
      echo "$SOLR_SHA512 */opt/solr-$SOLR_VERSION.tgz" | sha512sum -c -; \
      (>&2 ls -l "/opt/solr-$SOLR_VERSION.tgz" "/opt/solr-$SOLR_VERSION.tgz.asc"); \
      gpg --batch --verify "/opt/solr-$SOLR_VERSION.tgz.asc" "/opt/solr-$SOLR_VERSION.tgz"; \
    else \
        echo "Skipping GPG validation due to non-Apache build"; \
    fi; \
    tar -C /opt --extract --file "opt/solr-$SOLR_VERSION.tgz"; \
    mv "/opt/solr-$SOLR_VERSION" /opt/solr; \
    rm "/opt/solr-$SOLR_VERSION.tgz"*; \

    rm -Rf /opt/solr/docs/ /opt/solr/dist/{solr-core-$SOLR_VERSION.jar,solr-solrj-$SOLR_VERSION.jar,solrj-lib,solr-test-framework-$SOLR_VERSION.jar,test-framework}; \
     mkdir -p /opt/solr/server/solr/lib /docker-entrypoint-initdb.d /opt/docker-solr; \
  mkdir -p /opt/solr/server/solr/mycores /opt/solr/server/logs /opt/mysolrhome; \
  sed -i -e "s/\"\$(whoami)\" == \"root\"/\$(id -u) == 0/" /opt/solr/bin/solr; \
  sed -i -e 's/lsof -PniTCP:/lsof -t -PniTCP:/' /opt/solr/bin/solr; \
  if [ -f "/opt/solr/contrib/prometheus-exporter/bin/solr-exporter" ]; then chmod 0755 "/opt/solr/contrib/prometheus-exporter/bin/solr-exporter"; fi; \
  chmod -R 0755 /opt/solr/server/scripts/cloud-scripts; \
  chown -R "$SOLR_USER:$SOLR_GROUP" /opt/solr /docker-entrypoint-initdb.d /opt/docker-solr; \
  chown -R "$SOLR_USER:$SOLR_GROUP" /opt/mysolrhome; \
  { command -v gpgconf; gpgconf --kill all || :; }; \
  rm -r "$GNUPGHOME"

COPY --chown=solr:solr scripts /opt/docker-solr/scripts

EXPOSE 8983
WORKDIR /opt/solr
USER $SOLR_USER

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["solr-foreground"]









