variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
  default     = "t3.large"
}

variable "min_nodes" {
  description = "Minimum number of nodes"
  type        = number
  default     = 3
}

variable "max_nodes" {
  description = "Maximum number of nodes"
  type        = number
  default     = 10
}

variable "desired_nodes" {
  description = "Desired number of nodes"
  type        = number
  default     = 5
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15.3"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "db_storage_size" {
  description = "RDS storage size in GB"
  type        = number
  default     = 50
}

variable "redis_node_type" {
  description = "Redis node type"
  type        = string
  default     = "cache.t3.medium"
}

variable "chroma_version" {
  description = "Chroma version to deploy"
  type        = string
  default     = "0.4.2"
}

variable "public_key_path" {
  description = "Path to public key for EC2 instances"
  type        = string
}
