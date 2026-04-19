# HexIdeate Infrastructure Makefile

.PHONY: help dev-up dev-down dev-logs dev-build prod-init prod-plan prod-apply k8s-deploy k8s-status k8s-logs clean

help:
	@echo "HexIdeate Infrastructure Management"
	@echo ""
	@echo "Development (Docker Compose):"
	@echo "  make dev-up          - Start development environment"
	@echo "  make dev-down        - Stop development environment"
	@echo "  make dev-restart     - Restart development environment"
	@echo "  make dev-logs        - View development logs"
	@echo "  make dev-build       - Build development images"
	@echo "  make dev-health      - Check service health"
	@echo ""
	@echo "Production (AWS + Terraform):"
	@echo "  make terraform-init  - Initialize Terraform backend"
	@echo "  make tf-plan         - Plan infrastructure (env=dev or prod)"
	@echo "  make tf-apply        - Apply infrastructure (env=dev or prod)"
	@echo "  make tf-destroy      - Destroy infrastructure (env=dev or prod)"
	@echo ""
	@echo "Kubernetes:"
	@echo "  make k8s-deploy      - Deploy to Kubernetes"
	@echo "  make k8s-status      - Show K8s status"
	@echo "  make k8s-logs        - View K8s logs"
	@echo "  make k8s-down        - Remove Kubernetes deployment"
	@echo ""
	@echo "Utilities:"
	@echo "  make clean           - Clean up all resources"

# Development targets
dev-up:
	./deploy.sh start

dev-down:
	./deploy.sh stop

dev-restart:
	./deploy.sh restart

dev-logs:
	./deploy.sh logs

dev-build:
	./deploy.sh build

dev-health:
	./deploy.sh health

# Terraform targets
ENV ?= dev
REGION ?= us-east-1

terraform-init:
	python3 terraform/setup-backend.py

tf-plan:
	cd terraform/aws && \
	terraform init && \
	terraform plan -var-file="terraform.$(ENV).tfvars" -out=tfplan

tf-apply:
	cd terraform/aws && \
	terraform apply tfplan

tf-destroy:
	cd terraform/aws && \
	terraform destroy -var-file="terraform.$(ENV).tfvars"

tf-output:
	cd terraform/aws && \
	terraform output

# Kubernetes targets
k8s-deploy:
	chmod +x deploy-k8s.sh && \
	./deploy-k8s.sh

k8s-status:
	kubectl get all -n hexideate

k8s-logs:
	@kubectl logs -n hexideate -f deployment/gateway

k8s-down:
	kubectl delete namespace hexideate

# Utilities
clean:
	./deploy.sh cleanup
	rm -rf terraform/aws/.terraform
	rm -rf terraform/aws/*.tfstate*
	docker system prune -af

fmt:
	terraform fmt -recursive terraform/
	docker-compose config > /dev/null

lint:
	@echo "Linting Kubernetes manifests..."
	kubeval k8s/*.yaml || true
