FROM ubuntu:bionic-20200112
MAINTAINER Ceaser Larry

ENV LANG C.UTF-8
ENV TERM="xterm" LANG="C.UTF-8" LC_ALL="C.UTF-8"
ARG HOMEASSISTANT_VERSION
ENV HOMEASSISTANT_VERSION ${HOMEASSISTANT_VERSION:-0.99.2}
ARG HOMEASSISTANT_UID
ENV HOMEASSISTANT_UID ${HOMEASSISTANT_UID:-1000}
ARG HOMEASSISTANT_GID
ENV HOMEASSISTANT_GID ${HOMEASSISTANT_GID:-1000}
ENV CHANGE_CONFIG_DIR_OWNERSHIP true
ENV CHANGE_VENV_DIR_OWNERSHIP true
ENV CONFIG_DIR=/config

ARG DEB_PROXY
ENV DEB_PROXY ${DEB_PROXY}
RUN [ -z "$DEB_PROXY" ] || \
  echo "Acquire::http { Proxy \"$DEB_PROXY\"; };" > /etc/apt/apt.conf.d/02proxy

ARG DEBIAN_FRONTEND=noninteractive
RUN set -ex \
  && apt-get update \
  && apt-get install -y \
    software-properties-common \
  && add-apt-repository ppa:deadsnakes/ppa \
  && apt-get update \
  &&  apt-get install -y \
    python3.7 \
    autoconf \
    automake \
    build-essential \
    cmake \
    ffmpeg \
    gosu \
    libass-dev \
    libavcodec-dev \
    libavdevice-dev \
    libavfilter-dev \
    libavformat-dev \
    libavutil-dev \
    libffi-dev \
    libfreetype6-dev \
    libjpeg-dev \
    libssl-dev \
    libswresample-dev \
    libswscale-dev \
    libtheora-dev \
    libtool \
    libvorbis-dev \
    libx264-dev \
    libx264-dev \
    pkg-config \
    #python3-opencv \
    #python3-pip \
    python3.7-dev \
    python3.7-venv \
    unzip \
    wget \
    yasm \
    zlib1g-dev \
    locales \
    locales-all \
    curl \
  && apt-get clean \
  && mkdir /tmp/build && cd /tmp/build \
  && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
  && python3.7 get-pip.py \
  && pip3.7 install --upgrade pip \
  && cd / && rm -rf /tmp/build \
  && apt-get remove -y curl \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /config /srv/homeassistant

RUN locale-gen en_US.UTF-8 \
    && cd /srv/homeassistant \
    && python3.7 -m venv . \
    && . ./bin/activate \
    && pip3.7 install wheel \
    && pip3.7 install "homeassistant==$HOMEASSISTANT_VERSION"

## Create /config and ensure Home Assistant works
RUN /srv/homeassistant/bin/hass -c /config --script ensure_config \
  && /bin/rm -rf /config/* \
  && echo "C.UTF-8 UTF-8" > /etc/locale.gen \
  && locale-gen

COPY entry.sh /entry.sh
RUN chmod 755 /entry.sh
EXPOSE 8123/tcp
VOLUME ["/config"]
HEALTHCHECK --interval=5m --timeout=30s --retries=3 CMD nc -z 127.0.0.1 8123
ENTRYPOINT ["/entry.sh"]
CMD ["./srv/homeassistant/bin/hass", "-c", "/config"]
