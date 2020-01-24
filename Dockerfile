#FROM homeassistant/home-assistant:0.99.2
FROM debian:stable-slim

ARG HOMEASSISTANT_VERSION
ENV HOMEASSISTANT_VERSION ${HOMEASSISTANT_VERSION:-0.99.2}
ENV CONFIG_DIR=/config

RUN set -ex \
	# Install dependencies.
	&& apt-get update \
  && apt-get install -y \
    autoconf \
    automake \
    build-essential \
    cmake \
    ffmpeg \
    git \
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
    locales \
    pkg-config \
    python3-opencv \
    python3-pip \
    python3.7 \
    python3.7-dev \
    python3.7-venv \
    rsync \
    unzip \
    wget \
    yasm \
    zlib1g-dev \
	&& apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /config /srv/homeassistant

RUN cd /srv/homeassistant \
    && python3 -m venv . \
    && . /srv/homeassistant/bin/activate \
    && pip3 install wheel \
    && echo "$HOMEASSISTANT_VERSION" > /.version \
    && pip3 install "homeassistant==$HOMEASSISTANT_VERSION"

## Create /config and ensure Home Assistant works
RUN /srv/homeassistant/bin/hass -c /config --script ensure_config \
  && /bin/rm -rf /config/*

RUN useradd -rm homeassistant -G dialout \
    && chown -R homeassistant:homeassistant /config /srv/homeassistant \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

COPY entry.sh /entry.sh
RUN chmod 755 /entry.sh
EXPOSE 8123/tcp
VOLUME ["/config"]
HEALTHCHECK --interval=5m --timeout=30s --retries=3 CMD nc -z 127.0.0.1 8123
ENTRYPOINT ["/entry.sh"]
CMD ["./srv/homeassistant/bin/hass", "-c", "/config"]
