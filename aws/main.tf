terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "vault" {
  address = var.vault_host
}


data "terraform_remote_state" "deployer" {
  backend = "local"
  config = {
    path = var.deployer_tfstate_path
  }
}

data "vault_aws_access_credentials" "creds" {
  backend = data.terraform_remote_state.deployer.outputs.backend
  role    = data.terraform_remote_state.deployer.outputs.role-deployer
}


provider "aws" {
  region     = var.region_aws
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
}


resource "aws_vpc" "mlflow-vpc" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_internet_gateway" "mlflow-gw" {
  vpc_id = aws_vpc.mlflow-vpc.id
}

resource "aws_route_table" "mlflow-route-table" {
  vpc_id = aws_vpc.mlflow-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mlflow-gw.id
  }
}

resource "aws_subnet" "mlflow-app" {
  availability_zone = var.region
  vpc_id     = aws_vpc.mlflow-vpc.id
  cidr_block = var.ec2_cidr_block
}

resource "aws_route_table_association" "mlflow-route-table-association" {
  route_table_id = aws_route_table.mlflow-route-table.id
  subnet_id      = aws_subnet.mlflow-app.id
}

resource "aws_subnet" "mlflow-postgres" {
  availability_zone = var.region
  vpc_id     = aws_vpc.mlflow-vpc.id
  cidr_block = var.postgres_cidr_block
}
resource "aws_subnet" "mlflow-postgres-2" {
  availability_zone = var.region_db_2
  vpc_id     = aws_vpc.mlflow-vpc.id
  cidr_block = var.postgres_cidr_block2
}


resource "aws_db_subnet_group" "mlflow-postgres-subnet-group" {
  subnet_ids  = [aws_subnet.mlflow-postgres.id,aws_subnet.mlflow-postgres-2.id]
}
resource "aws_security_group" "ec2" {
  description = "EC2 security group (terraform-managed)"
  vpc_id      = aws_vpc.mlflow-vpc.id

  ingress {
    from_port   = var.postgres_port
    to_port     = var.postgres_port
    protocol    = "tcp"
    description = "Postgres"
    cidr_blocks = [var.postgres_cidr_block]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "MLFLOW"
    from_port   = var.ec2_port
    protocol    = "tcp"
    to_port     = var.ec2_port
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Telnet"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_security_group" "postgres" {
  description = "Postgres (terraform-managed)"
  vpc_id      = aws_vpc.mlflow-vpc.id

  # Postgres
  ingress {
    from_port   = var.postgres_port
    to_port     = var.postgres_port
    protocol    = "tcp"
    cidr_blocks = [var.ec2_cidr_block]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_network_interface" "web_server_nic" {
  subnet_id       = aws_subnet.mlflow-app.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.ec2.id]
}

resource "aws_eip" "mlflow-app-ip" {
  network_interface         = aws_network_interface.web_server_nic.id
  associate_with_private_ip = "10.0.1.50"
  vpc                       = true
  depends_on                = [aws_internet_gateway.mlflow-gw]
}

resource "tls_private_key" "ec2-private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2-pem" {
  key_name   = "ec2-pem"
  public_key = tls_private_key.ec2-private-key.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      echo "${tls_private_key.ec2-private-key.private_key_pem}" > ../ec2-key.pem
    EOT
  }
}


