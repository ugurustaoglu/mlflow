# MLFLOW installation to Openshift and AWS
This project demonstates a basic installation(MLFLOW) that contains S3 compatible device, a database and a web server.
MLFLOW is installed into a local openshift cluster(CRC - Code Ready Containers) with a basic YAML file, and with Terraform. An AWS cloud installation with Terraform is also demonstrated.
Installation of CRC, Minio and Using CRC repo as the target of Docker repository is explained in detail in crc-installation file. 
## crc folder - Local OpenShift Cluster Installation

   Prerequisites:
   1. Local Openshift is CRC - Code Ready Containers should be installed
   2. Local S3 compatible storage is Minio should be installed
   3. Docker image under the Dockerfiles folder should be pushed into the CRC repo
   
   Deployment.yaml file contains the necessary objects for Openshift based kubernetes installation.

## crc-tf folder - Local OpenShift Cluster Installation with Terraform

   Prerequisites:
   1. This is the same Openshift Cluster installation. All prerequisities from the first installation are necessary 
   2. Terraform should be installed
   
   After these installations, below terraform commands will deploy the environment.
      1. terraform init
      2. terraform plan
      3. terraform apply

## aws folder - Cloud Installation with Terraform

   Prerequisites:
   1. An aws account should be initialized
   2. aws-cli should be installed
   3. Terraform should be installed
   4. Local Hashicorp Vault should be installed

   In order to demonstrate secret management, a local vault is installed and a deployer user is created. Access and secret keys are stored in this vault.
   An EC2 and a Postgres based DB instances are created in different subnets. Necessary network settings are set. S3 bucket is created for MLFLOW backend and necessary files(requirement.txt in this case) are copyied into EC2 instance. IAM role is attached to EC2 instance for S3 communication.
   Basic terraform commands will deploy the MLOPS environment.
      1. terraform init
      2. terraform plan
      3. terraform apply

