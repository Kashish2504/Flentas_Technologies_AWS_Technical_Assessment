provider "aws" {
  region = "us-east-1"
}

variable "vpc_id" { 
    default = "vpc-010b08832c116804d"
}


variable "pub_sub_1" { default = "subnet-00ee163a82cc5ba1f" }
variable "pub_sub_2" { default = "subnet-04228a0b5649101bb" }


variable "priv_sub_1" { default = "subnet-0895af1e8ea99e602" }
variable "priv_sub_2" { default = "subnet-04541399e07143801" }


locals {
  name = "Kashish_Omar"
}


resource "aws_security_group" "alb_sg" {
  name   = "${local.name}_ALB_SG"
  vpc_id = var.vpc_id

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


resource "aws_security_group" "ec2_sg" {
  name   = "${local.name}_ASG_SG"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb" "app_lb" {
  name               = "Kashish-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [var.pub_sub_1, var.pub_sub_2]
}


resource "aws_lb_target_group" "tg" {
  name     = "Kashish-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path = "/"
    matcher = "200"
  }
}


resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}


resource "aws_launch_template" "lt" {
  name_prefix   = "Kashish-Template"
  image_id      = "ami-04b70fa74e45c3917" # Ubuntu 24.04
  instance_type = "t3.micro"  # <--- Using t3.micro to avoid error
  
  network_interfaces {
    associate_public_ip_address = false 
    security_groups             = [aws_security_group.ec2_sg.id]
  }

  user_data = filebase64("${path.module}/user_data.sh")
}


resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = [var.priv_sub_1, var.priv_sub_2]
  target_group_arns   = [aws_lb_target_group.tg.arn]
  
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
  
  tag {
    key                 = "Name"
    value               = "${local.name}_ASG_Instance"
    propagate_at_launch = true
  }
}

output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}