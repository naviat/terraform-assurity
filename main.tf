provider "aws" {
  access_key = "${var.aws_key}"
  secret_key = "${var.aws_secret}"
  region     = "${var.region}"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_availability_zones" "azs" {}

######################################
### Getting latest Ubuntu AMI id
######################################

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] #  Canonical Owner Code
}
############################################################
# VPC module for all network in Region 
############################################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "assurity-vpc"
  cidr   = "10.20.0.0/16"

  azs             = ["${element(data.aws_availability_zones.azs.names, 0)}", "${element(data.aws_availability_zones.azs.names, 1)}", "${element(data.aws_availability_zones.azs.names, 2)}"]
  private_subnets = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
  public_subnets  = ["10.20.101.0/24", "10.20.102.0/24", "10.20.103.0/24"]

  assign_generated_ipv6_cidr_block = true

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "overridden-name-public"
  }
}

########## SSH SG
module "ssh_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "2.9.0"

  name        = "assurity-ssh"
  description = "Security group which is used as an argrument for ssh access"
  vpc_id      = "${data.aws_vpc.default.id}"

  tags = {
    Name = "assurity-ssh"
  }

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
  egress_rules        = ["all-all"]
}


resource "aws_instance" "ec2_ubuntu" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  vpc_security_group_ids      = ["${module.ssh_sg.this_security_group_id}"]
  subnet_id                   = "${element(data.aws_subnet_ids.all.ids, 0)}"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "${var.key_name}"
  provisioner "remote-exec" {
        inline = [
        "sudo echo 'Hello Assurity DevOps' > /tmp/motd",
        "sudo cp /tmp/motd /etc/motd"
        ]
	connection{
		user = "ubuntu"
		private_key = "${file("${var.key_path}")}"
	}
    }
  tags                        = { Name = "Assurity"}
}

