#!/bin/bash
set -e

ENVIRONMENT=${1:-dev}
AWS_REGION=${2:-us-east-1}

echo "================================"
echo "HexIdeate Terraform Deployment"
echo "Environment: $ENVIRONMENT"
echo "Region: $AWS_REGION"
echo "================================"

# Navigate to terraform directory
cd terraform/aws

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Plan deployment
echo "Planning deployment..."
terraform plan -var-file="terraform.${ENVIRONMENT}.tfvars" -out=tfplan

# Show what will be deployed
echo ""
echo "Review the plan above. Do you want to proceed? (yes/no)"
read -r response

if [ "$response" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
fi

# Apply deployment
echo "Applying Terraform configuration..."
terraform apply tfplan

# Output important information
echo ""
echo "================================"
echo "Deployment Complete!"
echo "================================"
terraform output

echo ""
echo "To configure kubectl:"
terraform output -raw configure_kubectl | bash
