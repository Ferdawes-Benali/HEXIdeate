# HexIdeate Infrastructure Documentation

## Overview

This infrastructure setup provides complete deployment configurations for the HexIdeate healthcare platform across multiple environments:

- **Development**: Docker Compose for local development
- **Staging/Production**: Kubernetes (EKS) with Terraform for cloud infrastructure
- **Cloud Provider**: AWS (easily adaptable to GCP or Azure)

## Architecture

```
┌─────────────────────────────────────────────┐
│        Mobile App (Flutter)                 │
│   (iOS/Android - connects to API)           │
└────────────────┬────────────────────────────┘
                 │ HTTPS
                 ▼
┌─────────────────────────────────────────────┐
│    API Gateway (Ingress)                    │
│    - Authentication                         │
│    - Rate Limiting                          │
│    - Request Routing                        │
└────────────────┬────────────────────────────┘
                 │
    ┌────────────┼────────────┐
    │            │            │
    ▼            ▼            ▼
┌─────────┐ ┌─────────┐ ┌─────────┐
│ Agent   │ │ Vision  │ │ Voice   │
│ Service │ │ Service │ │ Service │
└────┬────┘ └────┬────┘ └────┬────┘
     │           │           │
     └───────────┼───────────┘
                 │
     ┌───────────┼───────────┐
     │           │           │
     ▼           ▼           ▼
┌─────────┐ ┌────────┐ ┌──────────┐
│ Redis   │ │Postgres│ │ Chroma   │
│ Cache   │ │Database│ │ Vector DB│
└─────────┘ └────────┘ └──────────┘
```

## Quick Start

### Development Setup

1. **Clone and navigate to infra directory:**
   ```bash
   cd infra
   ```

2. **Configure environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Start services:**
   ```bash
   # Using the deploy script
   ./deploy.sh start

   # Or using docker-compose directly
   docker-compose up -d
   ```

4. **Verify services:**
   ```bash
   ./deploy.sh health
   docker-compose ps
   ```

5. **Access services:**
   - API Gateway: http://localhost:8080
   - Agent Service: http://localhost:8005
   - Vision Service: http://localhost:8001
   - Voice Service: http://localhost:8002
   - Analytics Service: http://localhost:8003
   - Notification Service: http://localhost:8004
   - Chroma Vector DB: http://localhost:8000

### View Logs

```bash
# All services
./deploy.sh logs

# Specific service
./deploy.sh logs gateway
docker-compose logs -f agent-service
```

### Stop Services

```bash
./deploy.sh stop
```

## Docker Compose Configuration

### Services Included

| Service | Port | Description |
|---------|------|-------------|
| PostgreSQL | 5432 | Primary database |
| Redis | 6379 | Caching & session memory |
| Chroma | 8000 | Vector database for RAG |
| Gateway | 8080 | API entry point |
| Agent Service | 8005 | AI agent logic |
| Vision Service | 8001 | Pill detection |
| Voice Service | 8002 | Speech-to-text/text-to-speech |
| Analytics Service | 8003 | ML predictions |
| Notification Service | 8004 | Alert dispatching |

### Health Checks

All services include health checks that are run automatically:
- Every 10 seconds after initial delay
- Services restart automatically on failure

## Kubernetes Deployment

### Prerequisites

- Terraform >= 1.0
- kubectl configured for your cluster
- AWS CLI configured (for AWS deployments)
- Helm (optional, for advanced configurations)

### Step 1: Initialize Terraform Backend

```bash
# Create S3 bucket and DynamoDB table for state management
python3 terraform/setup-backend.py
```

### Step 2: Deploy Infrastructure

```bash
# Initialize Terraform
cd terraform/aws
terraform init

# Plan deployment (dev environment)
terraform plan -var-file="terraform.dev.tfvars" -out=tfplan

# Apply configuration
terraform apply tfplan
```

### Step 3: Deploy Kubernetes Manifests

```bash
cd ../../..

# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name hexideate-prod

# Deploy services
chmod +x infra/deploy-k8s.sh
infra/deploy-k8s.sh
```

### Kubernetes Manifests

The `k8s/` directory contains:

- **01-infrastructure.yaml**: PostgreSQL, Redis, ConfigMaps, Secrets
- **02-services.yaml**: Microservices (Vision, Voice, Analytics, Notification, Chroma)
- **03-gateway-agent.yaml**: Agent Service, API Gateway, Ingress
- **04-scaling-network.yaml**: HPA, Network Policies, Pod Disruption Budgets

### Scaling & Auto-scaling

Services are configured with horizontal pod autoscaling:

- **Agent Service**: 3-10 replicas (CPU: 70%, Memory: 80%)
- **Vision Service**: 2-8 replicas (CPU: 70%)
- **Voice Service**: 2-8 replicas (CPU: 70%)
- **Analytics Service**: 2-6 replicas (CPU: 75%)
- **Gateway**: 3-10 replicas (CPU: 70%, Memory: 80%)

### View Kubernetes Status

```bash
# All resources in namespace
kubectl get all -n hexideate

# Deployments
kubectl get deployments -n hexideate

# Services
kubectl get services -n hexideate

# Pods
kubectl get pods -n hexideate

# Pod logs
kubectl logs -n hexideate -f deployment/gateway

# Describe pod for issues
kubectl describe pod <pod-name> -n hexideate
```

## Terraform Configuration

### Directory Structure

```
terraform/
├── aws/
│   ├── main.tf              # EKS cluster, RDS, Redis, VPC
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Output values
│   ├── terraform.dev.tfvars # Dev environment variables
│   ├── terraform.prod.tfvars # Prod environment variables
│   └── chroma-init.sh      # Chroma setup script
└── setup-backend.py        # Initialize backend infrastructure
```

### AWS Resources Created

1. **VPC with public/private subnets** across 3 availability zones
2. **EKS Cluster** with managed node groups (general + GPU)
3. **RDS PostgreSQL** with automated backups and multi-AZ
4. **ElastiCache Redis** for caching and sessions
5. **EC2 Instance** for Chroma Vector DB
6. **S3 Bucket** for model storage
7. **Security Groups** for network access control
8. **CloudWatch Logs** for monitoring

### Environment-Specific Configuration

#### Development (`terraform.dev.tfvars`)
- Smaller instance types
- 1-3 nodes (desired: 2)
- Smaller database and cache
- Lower costs, minimal redundancy

#### Production (`terraform.prod.tfvars`)
- Larger instance types
- 3-10 nodes (desired: 5)
- Larger database and cache
- Multi-AZ redundancy
- Production-grade resources

### Deployment Process

```bash
# 1. Initialize backend (first time only)
make terraform-init

# 2. Plan infrastructure for dev
make tf-plan env=dev

# 3. Apply configuration
make tf-apply env=dev

# 4. View outputs
make tf-output
```

### Managing State

Terraform state is stored in S3 with:
- Versioning enabled
- Server-side encryption (AES256)
- State locking via DynamoDB
- Public access blocked

## Configuration & Secrets Management

### Environment Variables

All services read configuration from:
1. Environment variables
2. ConfigMaps (Kubernetes)
3. Secrets (Kubernetes)
4. `.env` file (Docker Compose)

### Sensitive Data Handling

- **Secrets** are stored in AWS Secrets Manager (Terraform)
- **ConfigMaps** contain non-sensitive configuration
- **`.env` file** should never be committed to version control

### Required Environment Variables

See `.env.example` for complete list:

```bash
DB_NAME=hexideate
DB_USER=postgres
DB_PASSWORD=<strong_password>
GOOGLE_API_KEY=<your_api_key>
JWT_SECRET_KEY=<your_jwt_secret>
LOG_LEVEL=info
```

## Deployment with Make

Simplified deployment using Makefile:

```bash
# Development
make dev-up                  # Start services
make dev-logs               # View logs
make dev-build              # Rebuild images
make dev-health             # Check health

# Terraform (AWS)
make terraform-init         # Setup backend
make tf-plan env=prod       # Plan production deployment
make tf-apply env=prod      # Deploy to AWS

# Kubernetes
make k8s-deploy             # Deploy to K8s
make k8s-status             # Show status
make k8s-logs               # View logs

# Cleanup
make clean                  # Remove everything
```

## Monitoring & Logging

### CloudWatch (AWS)
- RDS performance metrics
- EKS cluster metrics
- Application logs (if configured)

### Kubernetes Logging
```bash
# View pod logs
kubectl logs -n hexideate pod/<pod-name>

# Stream logs in real-time
kubectl logs -n hexideate -f deployment/gateway

# Logs from multiple pods
kubectl logs -n hexideate -l app=gateway --all-containers=true
```

### Health Checks

Each service exposes a `/health` endpoint:
```bash
curl http://localhost:8080/health
curl http://localhost:8005/health
```

## Backup & Disaster Recovery

### Database Backups
- **RDS**: Automated daily backups with 30-day retention
- **Restore**: Point-in-time recovery available

### Redis Snapshots
- Enabled in ElastiCache configuration
- Daily snapshots with 7-day retention

### Chroma Data
- Persisted to S3 (production)
- Local volume (development)

## Troubleshooting

### Services not starting
```bash
# Check logs
docker-compose logs <service>
kubectl logs -n hexideate deployment/<service>

# Check resource limits
docker stats
kubectl top nodes -n hexideate
```

### Database connection issues
```bash
# Test PostgreSQL connection
docker-compose exec postgres psql -U postgres -d hexideate -c "SELECT 1"

# Check database URL
echo $DATABASE_URL
```

### Redis connectivity
```bash
# Test Redis
docker-compose exec redis redis-cli ping

# Check Redis info
docker-compose exec redis redis-cli info
```

### Kubernetes pod issues
```bash
# Describe pod for events
kubectl describe pod <pod-name> -n hexideate

# Check resource usage
kubectl top pod -n hexideate

# Get pod logs
kubectl logs -n hexideate <pod-name>
```

## Cost Optimization

### Development
- Use spot instances for EC2
- Right-size database instances
- Use on-demand for databases (or scheduled shutdowns)

### Production
- Use reserved instances for predictable workloads
- Enable auto-scaling to handle traffic spikes
- Use spot instances for non-critical workloads
- Monitor CloudWatch for optimization opportunities

## Security Best Practices

1. **Network Security**
   - VPC with private subnets
   - Security groups restrict inbound traffic
   - Network policies in Kubernetes

2. **Data Encryption**
   - TLS for in-transit data
   - AES256 for at-rest data (S3, RDS)
   - Secrets Manager for sensitive values

3. **Access Control**
   - IAM roles for AWS resources
   - RBAC for Kubernetes
   - JWT authentication for API access

4. **Compliance**
   - Audit logging enabled
   - Regular backups
   - Data retention policies

## Useful Commands

### Docker Compose
```bash
# View all services
docker-compose ps

# Restart service
docker-compose restart gateway

# Execute command in container
docker-compose exec gateway bash

# Remove all containers and volumes
docker-compose down -v
```

### Kubernetes
```bash
# Apply configuration
kubectl apply -f k8s/

# Get all resources
kubectl get all -n hexideate

# Port forward to local machine
kubectl port-forward -n hexideate svc/gateway 8080:8000

# Port forward to pod
kubectl port-forward -n hexideate pod/gateway-xxx 8080:8000

# Execute command in pod
kubectl exec -n hexideate -it <pod-name> -- bash

# Scale deployment
kubectl scale deployment gateway -n hexideate --replicas=5
```

### Terraform
```bash
# Format configuration files
terraform fmt -recursive terraform/

# Validate configuration
terraform validate

# View current state
terraform show

# Destroy infrastructure
terraform destroy

# Target specific resource
terraform apply -target module.rds

# Unlock state (if locked)
terraform force-unlock <LOCK_ID>
```

## Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## Support & Maintenance

### Regular Tasks
- Monitor resource usage
- Review security logs
- Update Docker images
- Apply Kubernetes patches
- Rotate secrets periodically

### Updating Services
```bash
# Update image tag in Kubernetes
kubectl set image deployment/gateway \
  gateway=hexideate/gateway:v2.0.0 -n hexideate

# Docker Compose: rebuild and restart
docker-compose up -d --build
```

## Next Steps

1. ✅ Set up `.env` file with your configuration
2. ✅ Start local development environment
3. ✅ Configure AWS credentials
4. ✅ Initialize Terraform backend
5. ✅ Deploy to AWS EKS
6. ✅ Configure monitoring and logging
7. ✅ Set up CI/CD pipelines

---

Last Updated: 2024
For latest documentation and updates, refer to the project README.
