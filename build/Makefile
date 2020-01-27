.PHONY: build run stop shell clean distclean push pull cacher_ip

DOCKER_REPO=registry.home.divergentlogic.com
DOCKER_APPNAME=home-assistant
VERSION=$(shell git describe --tags 2> /dev/null || echo "latest")
#ARGS=-p 8123:8123 -v $(shell pwd)/../venv:/venv -v $(shell pwd)/../config:/config -v $(shell pwd)/../ccache:/root/.ccache --entrypoint bash
ARGS=-p 8123:8123 -v $(shell pwd)/../venv:/venv -v $(shell pwd)/../config:/config  -v $(shell pwd)/../ssh:/home/homeassistant/.ssh -v $(shell pwd)/../ca-certificates:/usr/local/share/ca-certificates --entrypoint bash
#BUILD_ARGS=--build-arg DEB_PROXY=http://172.17.0.2:3142 --build-arg MAKE_JOBS=8 --build-arg DISTCC_POTENTIAL_HOSTS="distcc1 distcc2 distcc3 distcc4 distcc5" --build-arg CC="distcc" --build-arg CCACHE_PREFIX="distcc make"
BUILD_ARGS=--build-arg MAKE_JOBS=8
BUILD_OBJS=.cacher

build: .cacher
	docker build $(BUILD_ARGS) -t "$(DOCKER_REPO)/$(DOCKER_APPNAME):latest" .

run:
	docker run -it $(ARGS) --rm --name "$(DOCKER_APPNAME)" "$(DOCKER_REPO)/$(DOCKER_APPNAME):latest"

shell:
	docker exec -it "${DOCKER_APPNAME}" bash

clean:
	-docker stop ${DOCKER_APPNAME}
	-docker rm -v ${DOCKER_APPNAME}
	-rm $(BUILD_OBJS)
	-docker stop apt-cacher-ng > /dev/null
	-docker rm apt-cacher-ng > /dev/null

push:
	#docker tag "$(DOCKER_REPO)/$(DOCKER_APPNAME):latest" "$(DOCKER_REPO)/$(DOCKER_APPNAME):$(VERSION)"
	docker push "$(DOCKER_REPO)/$(DOCKER_APPNAME):$(VERSION)"
	docker push "$(DOCKER_REPO)/$(DOCKER_APPNAME):latest"

pull:
	docker pull "$(DOCKER_REPO)/$(DOCKER_APPNAME):latest

## Add Top of Docker File
## Optimizations to speed up builds
#ARG DISTCC_POTENTIAL_HOSTS
#ENV DISTCC_POTENTIAL_HOSTS ${DISTCC_POTENTIAL_HOSTS}
#ARG CC
#ENV CC ${CC}
#ARG DEB_PROXY
#ENV DEB_PROXY ${DEB_PROXY}
#RUN [ -z "$DEB_PROXY" ] || \
  #echo "Acquire::http { Proxy \"$DEB_PROXY\"; };" > /etc/apt/apt.conf.d/02proxy
#ARG DEBIAN_FRONTEND=noninteractive
#RUN set -ex \
  #&& apt-get update \
  #&& apt-get install -y \
    #ccache g++ gcc clang distcc distcc-pump \
  #&& apt-get autoclean -y \
  #&& apt-get autoremove -y \
  #&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  #&& mkdir -p /root/.ccache/ /root/.distcc/

#ADD "distcc-wrap.sh" /usr/local/bin/distcc-wrap.sh
#ADD distcc_hosts /root/.distcc/hosts
#ADD ccache.conf /root/.ccache/cache.conf
#RUN set -e \
  #&& chown root:root /usr/local/bin/distcc-wrap.sh \
  #&& chmod 775 /usr/local/bin/distcc-wrap.sh

# ...
#
## Add to the end of the Docker file
## Clean optimizations to speed up builds
#RUN set -ex \
  #&& apt-get purge -y \
    #ccache g++ gcc clang distcc distcc-pump \
  #&& apt-get autoclean -y \
  #&& apt-get autoremove -y \
  #&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.ccache /root/.distcc

.cacher:
	docker run --name apt-cacher-ng --init -d --restart=always \
  --publish 3142:3142 \
	--volume $(shell pwd)/../cache:/var/cache/apt-cacher-ng \
  sameersbn/apt-cacher-ng:3.1-3
	touch .cacher

cacher_ip:
	docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' apt-cacher-ng

