# AWS - Terraform
region         = "us-east-1a"
region_db_2    = "us-east-1b"
region_aws     = "us-east-1"
vpc_cidr_block = "10.0.0.0/16"

# Vault
deployer_tfstate_path = "../vault-admin-workspace/terraform.tfstate"
vault_host            = "http://127.0.0.1:8200"

# EC2
ubuntu_ami           = "ami-052efd3df9dad4825"
ubuntu_instance_type = "t2.micro"
ec2_cidr_block       = "10.0.1.0/24"
ec2_port             = 5000

# Postgres
postgres_engine              = "postgres"
postgres_engine_version      = "14.2"
postgres_instance_class      = "db.t3.micro"
postgres_db_name             = "mflow_db"
postgres_username            = "mlflow_user"
postgres_password            = "mlflow_pwd"
postgres_port                = 5432
postgres_allocated_storage   = 10
postgres_storage_encrypted   = false # not supported for db.t2.micro instance
postgres_skip_final_snapshot = true
postgres_publicly_accessible = false
postgres_multi_az            = false
postgres_cidr_block          = "10.0.2.0/24"
postgres_cidr_block2          = "10.0.3.0/24"

# S3
s3_bucketname              = "mlflow-s3-test-ugur"
s3_block_public_acls       = true
s3_block_public_policy     = true
s3_ignore_public_acls      = true
s3_restrict_public_buckets = true