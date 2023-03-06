MODULE = $(shell go list -m)
VERSION ?= $(shell git describe --tags --always --dirty --match=v* 2> /dev/null || echo "1.0.0")
LDFLAGS := -ldflags "-X main.Version=${VERSION}"
CONTAINER_NAME=dotnetsamplewebapi
DOCKER_RUNNING_PORT=8085
GCP_PROJECT_NAME=bubbly-yeti-377212
DOCKER_TAG_VERSION=5

.PHONY: default
default: help

.PHONY: help
help: ## help information about make commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build:  ## build the cli binary
	dotnet build

.PHONY: run
run: ## run the cli
	dotnet run

.PHONY: build-docker
docker-build: ## build the cli as a docker image
	docker build -f ./Dockerfile -t $(CONTAINER_NAME):$(DOCKER_TAG_VERSION) .

.PHONY: build-tag
docker-tag: ## build the cli as a docker image tag
	docker tag $(CONTAINER_NAME):$(DOCKER_TAG_VERSION) gcr.io/$(GCP_PROJECT_NAME)/$(CONTAINER_NAME):$(DOCKER_TAG_VERSION)

.PHONY: build-push
docker-push: ## build the cli as a docker image tag
	docker push gcr.io/$(GCP_PROJECT_NAME)/$(CONTAINER_NAME):$(DOCKER_TAG_VERSION)

.PHONY: kube-install
kube-install: ## install version into select kubernetes context
	envsubst < ./deployments/deployment-prod.yaml | kubectl apply -f -  
    envsubst < ./deployments/service-prod.yaml | kubectl apply -f -  
    #envsubst < ./deployments/ingress-prod.yaml | kubectl apply -f -  

.PHONY: dev-env-start
docker-run: ## build the cli as a docker image
	docker rm $(CONTAINER_NAME) -f

	docker run -it -p $(DOCKER_RUNNING_PORT):80 --name $(CONTAINER_NAME) $(CONTAINER_NAME):$(DOCKER_TAG_VERSION)

.PHONY: version
version: ## display the version of the cli
	@echo $(VERSION)

.PHONY: dev-env-stop
dev-env-stop: ## stop the services
	docker stop $(CONTAINER_NAME)