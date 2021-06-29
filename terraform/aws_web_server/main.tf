provider "aws" {
  region = var.region
}


data "aws_availability_zones" "available" {}


resource "aws_instance" "web_server1" {
  ami               = data.aws_ami.ami_amazon2.id
  instance_type     = var.instance_type
  availability_zone = data.aws_availability_zones.available.names[0]
  #security_groups   = [aws_security_group.HTTP.id]
  vpc_security_group_ids = [aws_security_group.HTTP.id]
  user_data = templatefile("user_data.sh.tpl", {
    server_name = "Server 1"
  })


  # network_interface {
  #   network_interface_id = aws_network_interface.server1_network_interface.id
  #   device_index         = 0
  # }

  tags = {
    Name = "Amazon_Linux1"
  }
}


resource "aws_instance" "web_server2" {
  ami               = data.aws_ami.ami_amazon2.id
  instance_type     = var.instance_type
  availability_zone = data.aws_availability_zones.available.names[0]
  #security_groups   = [aws_security_group.HTTP.id]
  vpc_security_group_ids = [aws_security_group.HTTP.id]
  user_data = templatefile("user_data.sh.tpl", {
    server_name = "Server 2"
  })

  # network_interface {
  #   network_interface_id = aws_network_interface.server2_network_interface.id
  #   device_index         = 0
  # }

  tags = {
    Name = "Amazon_Linux2"
  }
}


resource "aws_security_group" "HTTP" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "HTTP"
  }
}


resource "aws_lb_target_group" "HTTP" {
  name     = "http-lb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_default_vpc.default.id
}


resource "aws_lb_target_group_attachment" "HTTP_target_web1" {
  target_group_arn = aws_lb_target_group.HTTP.arn
  target_id        = aws_instance.web_server1.id
  port             = 80
}


resource "aws_lb_target_group_attachment" "HTTP_target_web2" {
  target_group_arn = aws_lb_target_group.HTTP.arn
  target_id        = aws_instance.web_server2.id
  port             = 80
}


resource "aws_lb" "web_lb" {
  name               = "tf-web-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_default_subnet.default_az1.id]

  enable_deletion_protection = true

  tags = {
    Name = "Web Load Balancer"
  }
}


resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.HTTP.arn
  }
}


resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}


resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Default subnet for zone1"
  }
}




/*
resource "aws_vpc" "web_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "Web vpc"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.web_vpc.id

  tags = {
    Name = "web-vpc"
  }
}


resource "aws_subnet" "web_subnet" {
  vpc_id            = aws_vpc.web_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "eu-central-1c"

  tags = {
    Name = "web subnet"
  }
}


resource "aws_network_interface" "server1_network_interface" {
  subnet_id       = aws_subnet.web_subnet.id
  private_ips     = ["172.16.10.10"]
  security_groups = [aws_security_group.HTTP.id]

  tags = {
    Name = "primary network interface instance1"
  }
}


resource "aws_network_interface" "server2_network_interface" {
  subnet_id       = aws_subnet.web_subnet.id
  private_ips     = ["172.16.10.11"]
  security_groups = [aws_security_group.HTTP.id]

  tags = {
    Name = "primary network interface instance2"
  }
}


resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}



resource "aws_network_interface" "" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}
*/
