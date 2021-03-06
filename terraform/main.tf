terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.32.0"
    }
  }
}


provider "aws" {
  profile = "default"
  region = "us-west-1"
}


//VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "saleschamp-vpc"
  cidr = "10.0.0.0/16"

  azs            = var.azs
  public_subnets = var.subnet_cidr
}


# Original AWS Instance creation
#resource "aws_instance" "web" {
  #ami           = var.ami
  #instance_type = "t2.micro"

  #count			= var.vms

  ## Persistent Storage
  #ebs_block_device {
    #device_name = "/dev/sdh"
    #volume_size = 5
    #volume_type = "gp2"
    #delete_on_termination = false
  #}

  ## Firewall for this VM
  #vpc_security_group_ids = [aws_security_group.security_grp.id]

  #subnet_id = module.vpc.public_subnets[count.index % length(module.vpc.public_subnets)]

  ## Attach IAM roles
  #iam_instance_profile = aws_iam_instance_profile.saleschamp_profile.name

  ## Attach Public key
  #key_name = aws_key_pair.deployer.id

  ## Use the Install.sh below for Provisioning setup
  #user_data = data.template_file.user_data.rendered

  #tags = {
    #Name = "saleschamp-vm-${count.index}"
	#DeployName = "main-instances"
  #}
#}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.public_key
}


# An AWS Application Load Balancer
resource "aws_lb" "alb" {
 name               = "saleschamp-alb"
 internal           = false
 load_balancer_type = "application"

 # Firewall for ALB
 security_groups    = [aws_security_group.security_grp.id]
 subnets            = module.vpc.public_subnets

  # Access Logs stored in an S3 bucket
  access_logs {
	bucket  = aws_s3_bucket.lb_logs.bucket
	prefix  = "alb"
	enabled = true
  }

  tags = {
    Environment = "production"
  }
}


# The S3 bucket for logs
resource "aws_s3_bucket" "lb_logs" {
  bucket        = "saleschamp-applb-logs"
  acl           = "log-delivery-write"
  force_destroy = true
	policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
	{
	  "Action": [
		"s3:PutObject"
	  ],
	  "Effect": "Allow",
	  "Resource": "arn:aws:s3:::saleschamp-applb-logs/alb/AWSLogs/*",
	  "Principal": {
		"AWS": [
		  "arn:aws:iam::027434742980:root"
		]
	  }
	}
  ]
}
POLICY
}

# Load Balancing target group for HTTP traffic, linked to the VPC
resource "aws_lb_target_group" "saleschamp" {
 name     = "saleschamp-http-vpc"
 port     = 80
 protocol = "HTTP"
 vpc_id   = module.vpc.vpc_id

  depends_on = [
    aws_lb.alb
  ]

  lifecycle {
    create_before_destroy = true
  }
}



# ALB listener on port 80
resource "aws_lb_listener" "alb_listener" {
 load_balancer_arn = aws_lb.alb.arn
 port              = "80"
 protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.saleschamp.arn
  }
}


# AWS instances launch template for the Autoscaling functionality
resource "aws_launch_template" "saleschamp-launch" {
  name_prefix   = "saleschamp-as-"
  image_id      = var.ami
  instance_type = "t2.micro"
  instance_initiated_shutdown_behavior = "terminate"

  # Attach Public key
  key_name = aws_key_pair.deployer.key_name

  # Security for Instances created by the autoscaler
  vpc_security_group_ids = [aws_security_group.security_grp.id]

  # External Disk
  block_device_mappings {
    device_name = "/dev/sdh"

    ebs {
      volume_size = var.v_size
      volume_type = var.v_type
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "saleschamp-vm-${random_id.server.id}"
	  DeployName = "main-instances"
    }
  }

  # Attach IAM roles
  iam_instance_profile {
    name = aws_iam_instance_profile.saleschamp_profile.name
  }

  user_data = base64encode(data.template_file.user_data.rendered)
}

resource "random_id" "server" {
  byte_length = 8
}


resource "aws_autoscaling_group" "saleschamp-aasg" {
  vpc_zone_identifier = module.vpc.public_subnets

  # Desired, maximum and minimum instances by the autoscaler

  desired_capacity   = 2
  max_size           = 4
  min_size           = 1
  
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true

  # Connect an Application Load Balancer
  #target_group_arns  = aws_lb_target_group.saleschamp.arn
  
  
  timeouts {
    delete = "15m"
  }

  # Use a template to launch new instances
  launch_template {
    id      = aws_launch_template.saleschamp-launch.id
	version = aws_launch_template.saleschamp-launch.latest_version
  }
}


# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "saleschamp" {
  autoscaling_group_name = aws_autoscaling_group.saleschamp-aasg.id
  alb_target_group_arn   = aws_lb_target_group.saleschamp.arn
}


## Security Group for ELB
resource "aws_security_group" "security_grp" {
name = "security_grp"
  description = "Ingress and Egress traffic allowing http and https traffic"

  vpc_id = module.vpc.vpc_id

  ingress {
    description = "HTTP from VPC"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = var.cidr_block
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = var.cidr_block
  }

  # SSH Access to Server
  ingress {
    description = "SSH from VPC"
    from_port   = 22
	to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.cidr_block
  }

  egress {
	# Outbound traffic is set to all
	from_port   = 0
	to_port     = 0
	protocol    = "-1"
    cidr_blocks = var.cidr_block
  }
}


// Using a Bash script for Initial Setup
data "template_file" "user_data" {
  template = file("install.sh")
  vars = {
	public_key = var.public_key
  }
}











data "aws_iam_policy_document" "saleschamp" {
  statement {
	actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}





resource "aws_iam_instance_profile" "saleschamp_profile" {
  name = "saleschamp_profile"
  role = aws_iam_role.saleschamp-iam.name
}


resource "aws_iam_role" "saleschamp-iam" {
  name = "saleschamp-iam"

  assume_role_policy = data.aws_iam_policy_document.saleschamp.json
}


resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.saleschamp-iam.name
}


resource "aws_codedeploy_app" "saleschamp" {
  name = "saleschamp-app"
}


resource "aws_codedeploy_deployment_group" "saleschamp" {
  app_name              = aws_codedeploy_app.saleschamp.name
  deployment_group_name = "saleschamp-group"
  service_role_arn      = aws_iam_role.saleschamp-iam.arn
  
  load_balancer_info {
    target_group_info {
      name = aws_lb.alb.name
    }
  }

  autoscaling_groups = [aws_autoscaling_group.saleschamp-aasg.id]
}
