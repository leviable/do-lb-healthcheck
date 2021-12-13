WORKDIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

REVISION := $(shell git rev-parse --short=8 HEAD)
TAG := $(shell git describe --tags --exact-match $(REVISION) 2>/dev/null)

REPO := ghcr.io/leviable
APP := do-lb-healthcheck
IMAGE := $(REPO)/$(APP):$(REVISION)
LATEST := $(REPO)/$(APP):latest

.PHONY: build
build:
	docker build \
		-t $(IMAGE) \
		-t $(LATEST) \
		--cache-from $(IMAGE) \
		--cache-from $(LATEST) \
		.

.PHONY: run
run:
	docker run --rm -it -p 8090:8080 $(IMAGE)

.PHONY: push
push:
	docker push $(IMAGE)
	docker push $(LATEST)

.PHONY: pull-latest
pull-latest:
	docker pull $(LATEST)

.PHONY: deploy
deploy:
	sed -i 's|<IMAGE>|$(IMAGE)|' $(WORKDIR)/config/deployment.yml
	kubectl apply -f $(WORKDIR)/config/deployment.yml
