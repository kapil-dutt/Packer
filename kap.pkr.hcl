packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_username" {
  type    = string
  default = "ec2-user"
}

source "amazon-ebs" "amazon-linux" {
  region                 = var.aws_region
  instance_type          = var.instance_type
  ami_name               = "AmazonLinux-Python-Docker"
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["amazon"]
    most_recent = true
  }
  ssh_username = var.ssh_username
  associate_public_ip_address = true
  ami_description = "Amazon Linux 2 AMI with Python, Pip, Docker, and Docker Compose"
}

build {
  sources = ["source.amazon-ebs.amazon-linux"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y python3",
      "sudo yum install -y python3-pip",
      "sudo yum install -y docker",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo curl -L https://github.com/docker/compose/releases/download/v2.5.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose"
    ]
  }
}
