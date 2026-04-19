# HexIdeate Infrastructure Quick Reference

## Quick Start Checklist

### Development Environment (5 minutes)

- [ ] Navigate to `infra` directory
- [ ] Copy `.env.example` to `.env`
- [ ] Update `.env` with your API keys
- [ ] Run `./deploy.sh start` (or `make dev-up`)
- [ ] Verify with `./deploy.sh health` (or `make dev-health`)

### Production Deployment (30 minutes)

- [ ] Configure AWS credentials
- [ ] Run `python3 terraform/setup-backend.py`
- [ ] Edit `terraform/aws/terraform.prod.tfvars`
- [ ] Run `make terraform-init` → `make tf-plan env=prod` → `make tf-apply env=prod`
- [ ] Configure kubectl: `aws eks update-kubeconfig --region us-east-1 --name hexideate-prod`
- [ ] Deploy Kubernetes: `make k8s-deploy`

## Common Commands

### Docker Compose (Development)

```bash
# Start
make dev-up

# Stop
make dev-down

# Logs
make dev-logs

# Health check
make dev-health

# Restart
make dev-restart
```

### Terraform (Infrastructure)

```bash
# Initialize
make terraform-init

# Plan
make tf-plan env=dev

# Apply
make tf-apply env=dev

# Destroy
make tf-destroy env=dev

# View outputs
make tf-output
```

### Kubernetes (Production)

```bash
# Deploy
make k8s-deploy

# Status
make k8s-status

# Logs
make k8s-logs

# Scale
kubectl scale deployment gateway -n hexideate --replicas=5

# Access pod
kubectl exec -n hexideate -it pod/<name> -- bash
```

## Service Endpoints

### Development
- Gateway: `http://localhost:8080`
- Agent: `http://localhost:8005`
- Vision: `http://localhost:8001`
- Voice: `http://localhost:8002`
- Analytics: `http://localhost:8003`
- Notifications: `http://localhost:8004`

### Production (K8s)
```bash
# Get gateway endpoint
kubectl get svc -n hexideate gateway

# Port forward to local
kubectl port-forward -n hexideate svc/gateway 8080:8000
```

## Environment Variables

Required in `.env`:

```bash
DB_PASSWORD=<strong_password>
GOOGLE_API_KEY=<your_key>
JWT_SECRET_KEY=<your_key>
LOG_LEVEL=info
```

See `.env.example` for all variables.

## Troubleshooting

### Services won't start
```bash
# Check logs
docker-compose logs gateway

# Check resource availability
docker stats
```

### K8s pod issues
```bash
# Pod status
kubectl get pods -n hexideate

# Pod description
kubectl describe pod <name> -n hexideate

# Pod logs
kubectl logs -n hexideate <pod-name>
```

### Database connection failed
```bash
# Test connection
docker-compose exec postgres psql -U postgres -d hexideate -c "SELECT 1"

# Check DATABASE_URL
echo $DATABASE_URL
```

## File Structure

```
infra/
├── docker-compose.yml       # Development services
├── .env.example             # Environment template
├── deploy.sh                # Deployment script
├── Makefile                 # Make targets
├── README.md                # Full documentation
├── QUICK_REFERENCE.md       # This file
├── k8s/                     # Kubernetes manifests
│   ├── 01-infrastructure.yaml
│   ├── 02-services.yaml
│   ├── 03-gateway-agent.yaml
│   └── 04-scaling-network.yaml
└── terraform/               # Terraform code
    ├── setup-backend.py
    └── aws/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── terraform.dev.tfvars
        └── terraform.prod.tfvars
```

## Architecture Diagram

```
                   Mobile App
                       |
                 [API Gateway]
                   8080:8000
                  /  |  |  \
           [Agent] [Vision] [Voice] [Analytics] [Notifications]
                  \  |  |  /
         [PostgreSQL] [Redis] [Chroma]
```

## Key Files to Know

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Local dev environment |
| `.env.example` | Configuration template |
| `Makefile` | Shortcut commands |
| `k8s/01-infrastructure.yaml` | DB & cache setup |
| `terraform/aws/main.tf` | AWS infrastructure |

## Useful URLs

- **Local Gateway**: `http://localhost:8080`
- **Local Chroma**: `http://localhost:8000`
- **API Docs**: `http://localhost:8080/docs` (if Swagger enabled)

## Performance Tips

- Use `make dev-health` to quickly check service status
- Scale K8s deployments: `kubectl scale deployment <name> -n hexideate --replicas=N`
- Monitor resources: `docker stats`, `kubectl top nodes`
- Check logs: `kubectl logs -n hexideate -f deployment/gateway`

---

**Need help?** See `README.md` for detailed documentation.
