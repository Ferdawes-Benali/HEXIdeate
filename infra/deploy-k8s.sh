#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get cluster name
CLUSTER_NAME=${1:-hexideate-prod}
REGION=${2:-us-east-1}

# Check prerequisites
if ! command -v kubectl &> /dev/null; then
    log_error "kubectl is required but not installed"
    exit 1
fi

if ! command -v helm &> /dev/null; then
    log_error "helm is required but not installed"
    exit 1
fi

log_info "Deploying HexIdeate to Kubernetes cluster: $CLUSTER_NAME"

# Create namespace
log_info "Creating namespace..."
kubectl apply -f k8s/01-infrastructure.yaml

# Wait for postgres and redis
log_info "Waiting for database and cache to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/postgres -n hexideate
kubectl wait --for=condition=available --timeout=300s deployment/redis -n hexideate

# Deploy services
log_info "Deploying services..."
kubectl apply -f k8s/02-services.yaml
kubectl apply -f k8s/03-gateway-agent.yaml
kubectl apply -f k8s/04-scaling-network.yaml

# Wait for deployments
log_info "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=600s deployment/gateway -n hexideate

log_info "Deployment complete!"

# Show status
log_info "Checking deployment status..."
kubectl get deployments -n hexideate
kubectl get services -n hexideate
kubectl get pods -n hexideate

log_info "To access the API gateway:"
echo ""
kubectl get svc -n hexideate | grep gateway
echo ""
log_info "To view logs:"
echo "kubectl logs -n hexideate -f deployment/gateway"
