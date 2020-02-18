FROM haskell:8.0.1

ENV AGDA_VERSION 2.5.11
ENV AGDA_DIR /root/.agda

RUN apt-get update
RUN apt-get install -y curl

RUN stack install Agda-$AGDA_VERSION
RUN mkdir -p $AGDA_DIR/lib \
    && curl -SL https://github.com/agda/agda-stdlib/archive/v0.12.tar.gz \
    | tar -xzC $AGDA_DIR/lib \
    && echo 'standard-library' > $AGDA_DIR/defaults \
    && echo '${AGDA_DIR}/lib/agda-stdlib-0.12/standard-library.agda-lib' \
    > $AGDA_DIR/libraries-$AGDA_VERSION
RUN apt-get install -y emacs-nox
RUN mkdir /root/.emacs.d
COPY init.el /root/.emacs.d

ENV TERM=xterm-256color



