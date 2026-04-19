# Development environment
environment = "dev"
aws_region  = "us-east-1"

kubernetes_version = "1.28"
instance_type      = "t3.medium"
min_nodes          = 1
max_nodes          = 3
desired_nodes      = 2

db_instance_class = "db.t3.micro"
db_storage_size   = 20
redis_node_type   = "cache.t3.micro"

public_key_path = "~/.ssh/id_rsa.pub"
