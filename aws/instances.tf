
resource "aws_db_instance" "mlflow-db" {

  availability_zone      = var.region
  allocated_storage      = var.postgres_allocated_storage
  engine                 = var.postgres_engine
  engine_version         = var.postgres_engine_version
  instance_class         = var.postgres_instance_class
  db_name                = var.postgres_db_name
  username               = var.postgres_username
  password               = var.postgres_password
  port                   = var.postgres_port
  multi_az               = var.postgres_multi_az
  db_subnet_group_name   = aws_db_subnet_group.mlflow-postgres-subnet-group.id
  skip_final_snapshot    = var.postgres_skip_final_snapshot
  storage_encrypted      = var.postgres_storage_encrypted
  publicly_accessible    = var.postgres_publicly_accessible
  vpc_security_group_ids = [aws_security_group.postgres.id]
}

resource "aws_instance" "mlflow-app" {
  ami                  = var.ubuntu_ami
  instance_type        = var.ubuntu_instance_type
  availability_zone    = var.region
  key_name             = aws_key_pair.ec2-pem.key_name
  iam_instance_profile = aws_iam_instance_profile.SSMRoleForEC2.name
  depends_on           = [aws_db_instance.mlflow-db]
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web_server_nic.id
  }

  user_data = <<-EOF
      #!/bin/bash
      sudo apt update -y
      export DEBIAN_FRONTEND="noninteractive"
      export MLFLOW_TRACKING_INSECURE_TLS="true"
      export MLFLOW_S3_IGNORE_TLS=true
      sudo apt install -y --no-install-recommends python3-pip unzip
      cd /home/ubuntu
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo aws/install
      sudo aws s3 cp --recursive s3://${var.s3_bucketname}/ .

      sudo python3 -m pip install -r /home/ubuntu/requirements.txt --upgrade
      sudo mlflow server --host=0.0.0.0 --port=${var.ec2_port} --backend-store-uri=postgresql://${var.postgres_username}:${var.postgres_password}@${aws_db_instance.mlflow-db.endpoint}:${var.postgres_port}/${var.postgres_db_name} --default-artifact-root=s3://${var.s3_bucketname}/ --workers=2
EOF
}
