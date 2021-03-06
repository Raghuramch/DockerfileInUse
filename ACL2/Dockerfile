FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    automake \
    autoconf \
    libcur14-openssl-dev \
    ca-certificates \
    libssl-dev \
    wget \
    perl \
    sbcl \
    curl \
    unzip \
  && rm -rf /var/lib/apt/lists/* 
ADD fix-quicklisp.pl /tmp/

RUN cd /tmp && \
    curl -O https://beta.quicklisp.org/quicklisp.lisp && \
    sbcl --load quicklisp.lisp --quit --eval '(quicklisp-quickstart:install)' &&\
    perl /tmp/fix-quicklisp.pl

ARG ACL2_REPO_LATEST_COMMIT=0
RUN wget "https://api.github.com/repos/acl2/acl2/zipball/${ACL2_COMMIT}" -O /tmp/acl2.zip -q &&\
    unzip /tmp/acl2.zip -d /root/acl2_extract &&\
    rm /tmp/acl2.zip &&\
    mv /root/acl2_extract/$(ls /root/acl2_extract) /root/acl2 &&\
    rmdir /root/acl2_extract

ARG ACL2_BUILD_OPTS=""
ARG ACL2_CERTIFY_OPTS="-j 4"
ARG ACL2_CERTIFY_TARGETS="basic"

RUN cd /root/acl2 \
    && make LISP="sbcl" $ACL2_BUILD_OPTS \
    && cd books \
    && make $ACL2_CERTIFY_TARGETS ACL2=/root/acl2/saved_acl2 $ACL2_CERTIFY_OPTS

RUN apt-get remove -y \
    build-essential \
    git \
    automake \
    autoconf \
    unzip \
    && apt-get install -y --no-install-recommends make \
    && apt-get autoremove -y

RUN mkdir -p /opt/acl2/bin \
    && ln -s /root/acl2/saved_acl2 /opt/acl2/bin/acl2 \
    && ln -s /root/acl2/books/build/cert.pl /opt/acl2/bin/cert.pl \
    && ln -s /root/acl2/books/build/clean.pl /opt/acl2/bin/clean.pl \
    && ln -s /root/acl2/books/build/critpath.pl /opt/acl2/bin/critpath.pl

ENV PATH="/opt/acl2/bin:${PATH}"
ENV ACL2_SYSTEM_BOOKS="/root/acl2/books"
ENV ACL2="/root/acl2/saved_acl2"

CMD ["/root/acl2/saved_acl2"]
