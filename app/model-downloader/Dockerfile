FROM ubuntu:22.04

WORKDIR /workdir

RUN apt-get update && apt-get install -y \
    curl \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY . /workdir/

ENTRYPOINT [ "/workdir/download-decrypt-model.sh" ]
