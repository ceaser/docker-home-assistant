.PHONY: build run stop shell clean distclean push pull cacher_ip

DOCKER_REPO=registry.home.divergentlogic.com
DOCKER_APPNAME=home-assistant
VERSION=$(shell git describe --tags 2> /dev/null || echo "latest")
ARGS=-p 8123:8123 -v $(shell pwd)/venv:/venv -v $(shell pwd)/config:/config
BUILD_ARGS=--build-arg DEB_PROXY=http://172.17.0.2:3142
BUILD_OBJS=.cacher

build: .cacher
	docker build $(BUILD_ARGS) -t "$(DOCKER_REPO)/$(DOCKER_APPNAME):latest" .

run: build
	docker run -it $(ARGS) --rm --name="$(DOCKER_APPNAME)" "$(DOCKER_REPO)/$(DOCKER_APPNAME):latest"

shell:
	docker exec -it "${DOCKER_APPNAME}" bash

clean:
	-docker stop ${DOCKER_APPNAME}
	-docker rm -v ${DOCKER_APPNAME}
	-rm $(BUILD_OBJS)
	-docker stop apt-cacher-ng > /dev/null
	-docker rm apt-cacher-ng > /dev/null

push:
	docker tag "$(DOCKER_REPO)/$(DOCKER_APPNAME):latest "$(DOCKER_REPO)/$(DOCKER_APPNAME):$(VERSION)"
	docker push "$(DOCKER_REPO)/$(DOCKER_APPNAME):$(VERSION)"
	docker push "$(DOCKER_REPO)/$(DOCKER_APPNAME):latest"

pull:
	docker pull "$(DOCKER_REPO)/$(DOCKER_APPNAME):latest

.cacher:
	docker run --name apt-cacher-ng --init -d --restart=always \
  --publish 3142:3142 \
	--volume $(shell pwd)/cache:/var/cache/apt-cacher-ng \
  sameersbn/apt-cacher-ng:3.1-3
	touch .cacher

cacher_ip:
	docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' apt-cacher-ng
