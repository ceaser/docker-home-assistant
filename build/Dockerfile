FROM ubuntu:bionic-20200112
MAINTAINER Ceaser Larry

ENV LANG en_US.UTF-8

ARG DEBIAN_FRONTEND=noninteractive
RUN set -ex \
  && apt-get update \
  && apt-get install -y \
    software-properties-common \
  && add-apt-repository ppa:deadsnakes/ppa \
  && apt-get update \
  &&  apt-get install -y \
    autoconf \
    automake \
    build-essential \
    cmake \
    curl \
    ffmpeg \
    git \
    gosu \
    libass-dev \
    libatlas-base-dev \
    libavcodec-dev \
    libavdevice-dev \
    libavfilter-dev \
    libavformat-dev \
    libavutil-dev \
    libdc1394-22-dev \
    libffi-dev \
    libfreetype6-dev \
    libgtk-3-dev \
    libjpeg-dev \
    libpng-dev \
    libssl-dev \
    libswresample-dev \
    libswscale-dev \
    libtbb-dev \
    libtbb2 \
    libtheora-dev \
    libtiff-dev \
    libtool \
    libv4l-dev \
    libvorbis-dev \
    libx264-dev \
    libxvidcore-dev \
    locales \
    locales-all \
    openexr \
    pkg-config \
    python3.7 \
    python3.7-dev \
    python3.7-venv \
    unzip \
    wget \
    yasm \
    zlib1g-dev \
  && apt-get clean \
  && mkdir /tmp/build && cd /tmp/build \
  && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
  && python3.7 get-pip.py \
  && pip3.7 install --upgrade pip \
  && cd / && rm -rf /tmp/build \
  && apt-get remove -y curl \
  && apt-get autoclean -y \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG OPENCV_VERSION
ENV OPENCV_VERSION ${OPENCV_VERSION:-4.2.0}
ARG MAKE_JOBS=1
RUN set -ex \
  && pip3.7 install numpy \
  && add-apt-repository universe \
  && add-apt-repository main \
  && apt-get update \
  &&  apt-get install -y \
    gfortran \
  && mkdir /tmp/opencv_build && cd /tmp/opencv_build \
  && git clone -b $OPENCV_VERSION --depth 1 https://github.com/opencv/opencv.git \
  && git clone -b $OPENCV_VERSION --depth 1 https://github.com/opencv/opencv_contrib.git \
  && cd /tmp/opencv_build/opencv \
  && mkdir build \
  && cd /tmp/opencv_build/opencv/build \
  && cmake -D CMAKE_BUILD_TYPE=RELEASE \
     -D CMAKE_INSTALL_PREFIX=/usr/ \
     -D INSTALL_C_EXAMPLES=OFF \
     -D INSTALL_PYTHON_EXAMPLES=OFF \
     -D OPENCV_GENERATE_PKGCONFIG=OFF \
     -D OPENCV_EXTRA_MODULES_PATH=/tmp/opencv_build/opencv_contrib/modules \
     -D PYTHON_EXECUTABLE=/usr/bin/python3.7 \
     -D BUILD_NEW_PYTHON_SUPPORT=ON \
     -D BUILD_opencv_python2=OFF \
     -D BUILD_opencv_python3=ON \
     -D PYTHON_INCLUDE_DIR=/usr/include/python3.7 \
     -D PYTHON_LIBRARY=/usr/lib/python3.7/config-3.7m-x86_64-linux-gnu/libpython3.7.so \
     -D BUILD_EXAMPLES=OFF .. \
  && make -j$MAKE_JOBS \
  && make install \
  && /usr/local/bin/pip3.7 install -U opencv-python-headless \
  && /usr/local/bin/pip3.7 install -U opencv-contrib-python-headless \
  && apt-get remove -y \
    gfortran \
  && apt-get autoclean -y \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG BAZEL_VERSION
ENV BAZEL_VERSION ${BAZEL_VERSION:-0.21.0}
RUN set -ex \
  && apt-get update \
  && apt-get install -y pkg-config zip g++ zlib1g-dev unzip \
  && mkdir /tmp/bazel \
  && cd /tmp/bazel \
  && wget -q https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh \
  && wget -q https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh.sha256 \
  && sha256sum -c bazel-$BAZEL_VERSION-installer-linux-x86_64.sh.sha256 \
  && chmod +x bazel-$BAZEL_VERSION-installer-linux-x86_64.sh \
  && ./bazel-$BAZEL_VERSION-installer-linux-x86_64.sh \
  && ln -nfs /usr/bin/python3.7 /usr/bin/python \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /config /srv/homeassistant

ARG HOMEASSISTANT_VERSION
ENV HOMEASSISTANT_VERSION ${HOMEASSISTANT_VERSION:-0.99.2}
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && cd /srv/homeassistant \
    && python3.7 -m venv . \
    && . ./bin/activate \
    && pip3.7 install wheel \
    && cp -aR /usr/local/lib/python3.7/dist-packages/opencv* /srv/homeassistant/lib/python3.7/site-packages/ \
    && cp -aR /usr/local/lib/python3.7/dist-packages/cv2 /srv/homeassistant/lib/python3.7/site-packages/ \
    && pip3.7 install "homeassistant==$HOMEASSISTANT_VERSION" \
    && rm -rf /root/.cache/pip

## Create /config and ensure Home Assistant works
RUN /srv/homeassistant/bin/hass -c /config --script ensure_config \
  && /bin/rm -rf /config/* \
  && locale-gen

ARG HOMEASSISTANT_UID
ENV HOMEASSISTANT_UID ${HOMEASSISTANT_UID:-1000}
ARG HOMEASSISTANT_GID
ENV HOMEASSISTANT_GID ${HOMEASSISTANT_GID:-1000}
ENV CHANGE_CONFIG_DIR_OWNERSHIP true
ENV CHANGE_VENV_DIR_OWNERSHIP true
ENV CONFIG_DIR=/config

COPY entry.sh /entry.sh
RUN chmod 755 /entry.sh
EXPOSE 8123/tcp
VOLUME ["/config"]
HEALTHCHECK --interval=5m --timeout=30s --retries=3 CMD nc -z 127.0.0.1 8123
ENTRYPOINT ["/entry.sh"]
CMD ["/srv/homeassistant/bin/hass", "-c", "/config"]
