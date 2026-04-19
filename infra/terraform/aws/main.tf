terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "hexideate-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "HexIdeate"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

locals {
  cluster_name = "hexideate-${var.environment}"
}

# EKS Cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    general = {
      name           = "general-node-group"
      instance_types = [var.instance_type]
      capacity_type  = "SPOT"

      min_size     = var.min_nodes
      max_size     = var.max_nodes
      desired_size = var.desired_nodes

      disk_size = 50

      labels = {
        Environment = var.environment
        NodeGroup   = "general"
      }

      tags = {
        "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
        "k8s.io/cluster-autoscaler/enabled"               = "true"
      }
    }

    gpu = {
      name           = "gpu-node-group"
      instance_types = ["g4dn.xlarge"]
      capacity_type  = "SPOT"

      min_size     = 0
      max_size     = 3
      desired_size = 1

      taints = [{
        key    = "gpu"
        value  = "true"
        effect = "NoSchedule"
      }]

      labels = {
        NodeGroup = "gpu"
      }

      tags = {
        "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
      }
    }
  }

  manage_aws_auth_configmap = true

  cluster_addons = {
    coredns = {
      version = "v1.9.3-eksbuild.2"
    }
    kube-proxy = {
      version = "v1.28.1-eksbuild.1"
    }
    vpc-cni = {
      version = "v1.14.1-eksbuild.1"
    }
    ebs-csi-driver = {
      version = "v1.24.0-eksbuild.1"
    }
  }
}

# VPC Module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "hexideate-vpc"
  cidr = var.vpc_cidr

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "hexideate-vpc"
  }
}

# RDS PostgreSQL
module "rds" {
  source = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "hexideate-postgres"

  engine               = "postgres"
  engine_version       = var.postgres_version
  family               = "postgres15"
  major_engine_version = "15"
  instance_class       = var.db_instance_class

  allocated_storage     = var.db_storage_size
  max_allocated_storage = 100
  storage_encrypted     = true

  db_name  = "hexideate"
  username = "postgres"
  password = random_password.db_password.result

  multi_az = true
  publicly_accessible = false

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds.name

  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"

  skip_final_snapshot       = false
  final_snapshot_identifier = "hexideate-postgres-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  performance_insights_enabled = true
  performance_insights_retention_period = 7

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Name = "hexideate-postgres"
  }
}

# ElastiCache Redis
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "hexideate-redis"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379
  security_group_ids   = [aws_security_group.redis.id]
  subnet_group_name    = aws_elasticache_subnet_group.redis.name

  automatic_failover_enabled = false
  multi_az_enabled           = false
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_slow_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  tags = {
    Name = "hexideate-redis"
  }
}

# EC2 Instance for Chroma (or use managed service)
resource "aws_instance" "chroma" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.large"

  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.chroma.id]

  key_name = aws_key_pair.deployer.key_name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 50
    delete_on_termination = true
  }

  user_data = base64encode(templatefile("${path.module}/chroma-init.sh", {
    chroma_version = var.chroma_version
  }))

  tags = {
    Name = "hexideate-chroma"
  }
}

# S3 Bucket for model storage
resource "aws_s3_bucket" "models" {
  bucket = "hexideate-models-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "hexideate-models"
  }
}

resource "aws_s3_bucket_versioning" "models" {
  bucket = aws_s3_bucket.models.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "models" {
  bucket = aws_s3_bucket.models.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "redis_slow_log" {
  name              = "/aws/redis/hexideate-slow-log"
  retention_in_days = 7

  tags = {
    Name = "hexideate-redis-slow-log"
  }
}

# Security Groups
resource "aws_security_group" "rds" {
  name        = "hexideate-rds-sg"
  description = "Security group for RDS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "hexideate-rds-sg"
  }
}

resource "aws_security_group" "redis" {
  name        = "hexideate-redis-sg"
  description = "Security group for Redis"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "hexideate-redis-sg"
  }
}

resource "aws_security_group" "chroma" {
  name        = "hexideate-chroma-sg"
  description = "Security group for Chroma"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "hexideate-chroma-sg"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "rds" {
  name       = "hexideate-rds-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "hexideate-rds-subnet-group"
  }
}

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "redis" {
  name       = "hexideate-redis-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "hexideate-redis-subnet-group"
  }
}

# Random password for RDS
resource "random_password" "db_password" {
  length  = 32
  special = true
}

# Store password in Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name                    = "hexideate/rds/password"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id       = aws_secretsmanager_secret.db_password.id
  secret_string   = random_password.db_password.result
}

# Data sources
data "aws_caller_identity" "current" {}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# EC2 Key Pair for Chroma instance
resource "aws_key_pair" "deployer" {
  key_name   = "hexideate-deployer"
  public_key = file(var.public_key_path)
}
