SHELL := /usr/bin/env bash
IMAGE ?= infrastructure-operations-api
TAG ?= local
CLUSTER ?= enterprise-devops
NAMESPACE ?= enterprise-platform
RELEASE ?= enterprise-platform

.PHONY: setup test docker-build kind-up deploy health rollback troubleshoot scale logs clean
setup:
	python3 -m venv .venv
	.venv/bin/pip install -r requirements-dev.txt

test:
	.venv/bin/ruff check app tests
	.venv/bin/pytest

docker-build:
	docker build --build-arg APP_VERSION=$(TAG) -t $(IMAGE):$(TAG) .

kind-up:
	kind create cluster --config kubernetes/kind-config.yaml

deploy: docker-build
	kind load docker-image $(IMAGE):$(TAG) --name $(CLUSTER)
	kubectl apply -f kubernetes/base/namespace.yaml
	helm upgrade --install $(RELEASE) helm/enterprise-platform --namespace $(NAMESPACE) --set image.repository=$(IMAGE) --set image.tag=$(TAG) --wait --timeout 3m

health:
	NAMESPACE=$(NAMESPACE) ./scripts/health.sh

rollback:
	helm rollback $(RELEASE) 1 --namespace $(NAMESPACE) --wait

troubleshoot:
	NAMESPACE=$(NAMESPACE) ./scripts/troubleshoot.sh

scale:
	kubectl scale deployment/$(RELEASE) --replicas=$${REPLICAS:-3} -n $(NAMESPACE)

logs:
	kubectl logs -n $(NAMESPACE) deployment/$(RELEASE) --all-pods=true --tail=100 -f

clean:
	helm uninstall $(RELEASE) --namespace $(NAMESPACE) 2>/dev/null || true
	kubectl delete namespace $(NAMESPACE) --ignore-not-found
	kind delete cluster --name $(CLUSTER)
