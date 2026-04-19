# Production environment
environment = "prod"
aws_region  = "us-east-1"

kubernetes_version = "1.28"
instance_type      = "t3.large"
min_nodes          = 3
max_nodes          = 10
desired_nodes      = 5

db_instance_class = "db.t3.medium"
db_storage_size   = 100
redis_node_type   = "cache.t3.medium"

public_key_path = "~/.ssh/id_rsa.pub"
