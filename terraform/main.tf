terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"

  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  azs         = var.azs
}


# We are adding 2 security groups for the ALB and the Backend 
# where the ALB accept everything on port 80 and the Backend accept only from the ALB


resource "aws_security_group" "alb" {
  name   = "freshcart-${var.environment}-alb"
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

resource "aws_security_group" "backend" {
  name   = "freshcart-${var.environment}-backend"
  vpc_id = module.network.vpc_id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# We created an IAM role that ca access the EC2


resource "aws_iam_role" "backend" {
  name = "freshcart-${var.environment}-backend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}


# We gave the role permission to read the ECR 


resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.backend.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


# We create an instanceprofile that can access the EC2


resource "aws_iam_instance_profile" "backend" {
  name = "freshcart-${var.environment}-backend-profile"
  role = aws_iam_role.backend.name
}


# Added a data source that can find the latest Ubuntu AMI


data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


# We created the EC2 and attached the private subnet to install
# We enabled and start the Docker
# We pull the image from ECR then run it

resource "aws_instance" "backend" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = module.network.private_subnet_id
  vpc_security_group_ids = [aws_security_group.backend.id]

  iam_instance_profile = aws_iam_instance_profile.backend.name

  user_data = <<-EOF
              #!/bin/bash
              set -e

              apt-get update
              apt-get install -y docker.io

              systemctl enable docker
              systemctl start docker

              docker pull ${var.checkout_api_image}

              docker run -d \
                --name checkout-api \
                --restart unless-stopped \
                -p 3000:3000 \
                ${var.checkout_api_image}
              EOF

  tags = {
    Name        = "freshcart-${var.environment}-backend"
    Environment = var.environment
  }
}


# We created the ALB 


resource "aws_lb" "freshcart" {
  name               = "freshcart-${var.environment}"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb.id]

  subnets = module.network.public_subnet_ids

  tags = {
    Name        = "freshcart-${var.environment}-alb"
    Environment = var.environment
  }
}


# We added a target group for the ALB and the Backend 


resource "aws_lb_target_group" "checkout_api" {
  name     = "freshcart-${var.environment}"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = module.network.vpc_id

  health_check {
    path                = "/"
    port                = "3000"
    protocol            = "HTTP"
  }
}


# We attached the EC2 to the target group we created


resource "aws_lb_target_group_attachment" "backend" {
  target_group_arn = aws_lb_target_group.checkout_api.arn
  target_id        = aws_instance.backend.id
  port             = 3000
}


# We created the ALB listener and accept traffic from the aws_internet_gateway


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.freshcart.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.checkout_api.arn
  }
}













