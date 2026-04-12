terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "frontend_sg" {
  name   = "chatapp-frontend-sg"
  vpc_id = module.network.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend_sg" {
  name   = "chatapp-backend-sg"
  vpc_id = module.network.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "network" {
  source       = "./modules/network"
  vpc_cidr     = "10.0.0.0/16"
  az           = "us-east-1a"
  az_secondary = "us-east-1b"
}

module "cognito" {
  source = "./modules/cognito"
}

module "frontend" {
  source                = "./modules/frontend"
  vpc_id                = module.network.vpc_id
  public_subnet_id      = module.network.public_subnet_id
  backend_url           = module.backend.backend_url
  sg_id                 = aws_security_group.frontend_sg.id
  cognito_user_pool_id  = module.cognito.user_pool_id
  cognito_client_id     = module.cognito.client_id
}

module "backend" {
  source              = "./modules/backend"
  vpc_id              = module.network.vpc_id
  private_subnet_id   = module.network.private_subnet_id
  public_subnet_id    = module.network.public_subnet_id 
  db_endpoint         = module.rds.db_endpoint
  db_name             = module.rds.db_name
  db_username         = module.rds.username
  db_password         = var.db_password
  bucket_name         = module.s3.bucket_name
  sg_id               = aws_security_group.backend_sg.id
  cognito_issuer_uri  = module.cognito.issuer_uri
}

module "rds" {
  source             = "./modules/rds"
  vpc_id             = module.network.vpc_id
  db_name            = "chatapp"
  username           = "chatappuser"
  password           = var.db_password
  private_subnet_ids = module.network.private_subnet_ids
  backend_sg_id      = aws_security_group.backend_sg.id
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = "chatapp-s3-bucket-272648"
}
