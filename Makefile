SHELL := /bin/bash
APP_DIR := ./app
TF_AWS := terraform/aws
TF_LOCAL := terraform/localstack

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

.PHONY: install
install: ## Install app dependencies
	cd $(APP_DIR) && npm install

.PHONY: lint
lint: ## Lint the application
	cd $(APP_DIR) && npm run lint

.PHONY: test
test: ## Run application unit tests
	cd $(APP_DIR) && npm test

.PHONY: run
run: ## Run the application locally
	cd $(APP_DIR) && npm start

.PHONY: docker-build
docker-build: ## Build the application image
	docker build -t sample-web-app:local $(APP_DIR)

.PHONY: monitoring-up
monitoring-up: ## Start app, prometheus, alertmanager, grafana
	docker compose -f monitoring/docker-compose.yml up -d --build

.PHONY: monitoring-down
monitoring-down: ## Stop the monitoring stack
	docker compose -f monitoring/docker-compose.yml down -v

.PHONY: logging-up
logging-up: ## Start the ELK logging stack
	docker compose -f logging/docker-compose.yml up -d

.PHONY: logging-down
logging-down: ## Stop the ELK logging stack
	docker compose -f logging/docker-compose.yml down -v

.PHONY: tf-validate
tf-validate: ## Format check and validate terraform
	cd terraform && terraform fmt -check -recursive
	cd $(TF_AWS) && terraform init -backend=false -input=false && terraform validate
	cd $(TF_LOCAL) && terraform init -backend=false -input=false && terraform validate

.PHONY: tf-localstack
tf-localstack: ## Apply terraform against localstack
	./scripts/localstack-up.sh

.PHONY: vm
vm: ## Provision a local multipass VM and deploy with ansible
	./scripts/local-vm.sh

.PHONY: ansible-lint
ansible-lint: ## Lint ansible
	cd ansible && yamllint . && ansible-lint

.PHONY: clean
clean: ## Tear down local stacks and temporary state
	-docker compose -f monitoring/docker-compose.yml down -v
	-docker compose -f logging/docker-compose.yml down -v
	-docker rm -f localstack-main
	-rm -rf $(TF_LOCAL)/.terraform $(TF_LOCAL)/terraform.tfstate*
