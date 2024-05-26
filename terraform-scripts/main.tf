provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3"{
    bucket         = "victor-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "victor-state-file"
    encrypt        = true
  }
}

resource "aws_vpc" "vpc"{
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "victor-terraform-vpc"
  }
}

module "subnet-public"{
  name = "victor-terraform-subnet-public"
  source="./modules/subnet-module"
  vpc-id = "${aws_vpc.vpc.id}"
  cidr-block = "10.0.1.0/24"
  map-public-ip-on-launch = true
  depends_on = [ aws_vpc.vpc ]
}

module "subnet-private"{
  name = "victor-terraform-subnet-private"
  source="./modules/subnet-module"
  vpc-id = "${aws_vpc.vpc.id}"
  cidr-block = "10.0.2.0/24"
  depends_on = [ aws_vpc.vpc ]
}

resource "aws_internet_gateway" "IG"{
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "victor-terraform-IG"
  }
  depends_on = [ aws_vpc.vpc ]
}

module "rt-public"{
  name = "victor-terraform-rt-public"
  source="./modules/rt-module"
  vpc-id = "${aws_vpc.vpc.id}"
  cidr-block = "0.0.0.0/0"
  IG-id = "${aws_internet_gateway.IG.id}"
  subnet-id = module.subnet-public.subnet-id
  use-internet-gateway = true
  depends_on = [aws_internet_gateway.IG, module.subnet-public]
}

resource "aws_eip" "elastic-ip" {
  tags = {
    Name = "victor-terraform-elastic-ip"
  }
}

resource "aws_nat_gateway" "NG" {
  allocation_id = aws_eip.elastic-ip.id
  subnet_id = module.subnet-public.subnet-id
  tags = {
    Name = "victor-terraform-NG"
  }
  depends_on = [ module.subnet-public, aws_internet_gateway.IG , aws_eip.elastic-ip]
}

module "rt-private"{
  name = "victor-terraform-rt-private"
  source="./modules/rt-module"
  vpc-id = "${aws_vpc.vpc.id}"
  cidr-block = "0.0.0.0/0"
  NG-id = "${aws_nat_gateway.NG.id}"
  subnet-id = module.subnet-private.subnet-id
  use-internet-gateway = false
  depends_on = [aws_nat_gateway.NG, module.subnet-private]
}


module "ec2-openVPN"{
  name = "victor-terraform-openVPN"
  source="./modules/ec2-module"
  vpc-id = "${aws_vpc.vpc.id}"
  subnet-id = module.subnet-public.subnet-id
  volume-size = 30
  ingress-rules = [
    {
      from_port   = 1194
      to_port     = 1194
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "openVPN"
    }
  ]
  
  user-data = <<EOF
		#!/bin/bash
		yum update -y
    sudo yum install -y git
    sudo amazon-linux-extras install ansible2 -y
    sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64  
    sudo chmod +x /usr/local/bin/gitlab-runner
    sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
    gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
    gitlab-runner start
    gitlab-runner register --non-interactive --executor shell --url ${var.gitlab_instance_url} --registration-token ${var.registration_token} --executor shell
  EOF

 
  depends_on = [module.subnet-public]
}

module "ec2-RocketChat"{
  name = "victor-terraform-RocketChat"
  source="./modules/ec2-module"
  vpc-id = "${aws_vpc.vpc.id}"
  subnet-id = module.subnet-public.subnet-id
  volume-size = 30
  ingress-rules = [
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "RocketChat"
    }
  ]
  depends_on = [ module.subnet-public ]
}

module "ec2-NextCloud"{
  name = "victor-terraform-NextCloud"
  source="./modules/ec2-module"
  vpc-id = "${aws_vpc.vpc.id}"
  subnet-id = module.subnet-private.subnet-id
  volume-size = 30
  ingress-rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "NextCloud"
    }
  ]
  depends_on = [ module.subnet-private ]
}

module "ec2-Vault"{
  name = "victor-terraform-Vault"
  source="./modules/ec2-module"
  vpc-id = "${aws_vpc.vpc.id}"
  subnet-id = module.subnet-private.subnet-id
  volume-size = 30
  ingress-rules = [
    {
      from_port   = 8200
      to_port     = 8200
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Vault"
    }
  ]
  depends_on = [ module.subnet-private ]
}

module "db"{
  source = "./modules/db-module"
  subnet-id = [module.subnet-private.subnet-id, module.subnet-public.subnet-id]
  security_groups = [module.ec2-NextCloud.security-group-id, module.ec2-Vault.security-group-id]
  username = "${var.rds_username}"
  password = "${var.rds_password}"
  vpc-id = aws_vpc.vpc.id
}

resource "aws_s3_bucket" "backup-bucket" {
  bucket = "victor-terraform-backup"
}

