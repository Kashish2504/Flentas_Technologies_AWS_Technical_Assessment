provider "aws" {
  region = "us-east-1"
}


variable "my_vpc_id" {
  default = "vpc-010b08832c116804d"  
}

variable "my_public_subnet_id" {
  default = "subnet-00ee163a82cc5ba1f" 
}


locals {
  name_tag = "Kashish_Omar"
}


resource "aws_security_group" "web_sg" {
  name        = "${local.name_tag}_Web_SG"
  description = "Allow HTTP and SSH"
  vpc_id      = var.my_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_tag}_Web_SG"
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}


resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = var.my_public_subnet_id
  
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "${local.name_tag}_Resume_Server"
  }

  # This script installs Nginx and creates the Resume page
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install nginx -y
              echo "<html><head><title>Resume</title></head><body><center><h1>Kashish Omar</h1><h3>Full Stack Developer</h3><hr><p>Resume hosted on AWS EC2</p></center></body></html>" > /var/www/html/index.html
              systemctl start nginx
              EOF
}


output "website_url" {
  value = "http://${aws_instance.web_server.public_ip}"
}