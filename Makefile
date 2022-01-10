ifneq (,)
This makefile requires GNU Make.
endif

# Project-related variables
PROJECT:=gitlab-repos-backup
REGISTRY?=ghcr.io
OWNER:=bluesentry
VERSION?=$(shell git rev-parse HEAD)
DOCKER_IMAGE?=$(REGISTRY)/$(OWNER)/$(PROJECT)
VERSIONED_DOCKER_IMAGE?=$(DOCKER_IMAGE):$(VERSION)
LATEST_DOCKER_IMAGE?=$(DOCKER_IMAGE):latest

# Build and test tools abstraction
DOCKER:=$(shell which docker)

# target: make help - displays this help.
.PHONY: help
help:
	@egrep '^# target' [Mm]akefile

# target: make docker-login
.PHONY: docker-login
docker-login:
	$(DOCKER) login -u $(DOCKER_USERNAME) -p $(DOCKER_PASSWORD) $(REGISTRY)

# target: make build-docker VERSION=some_git_sha_comit
.PHONY: build-docker
build-docker-image: Dockerfile
	$(DOCKER) build -f Dockerfile -t $(VERSIONED_DOCKER_IMAGE) -t $(LATEST_DOCKER_IMAGE) .

# target: make release-docker-image VERSION=some_git_sha_comit
.PHONY: release-docker-image
release-docker-image: docker-login build-docker-image
	$(DOCKER) push $(VERSIONED_DOCKER_IMAGE)
	$(DOCKER) push $(LATEST_DOCKER_IMAGE)
