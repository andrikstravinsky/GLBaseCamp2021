variable "region" {
  default = "eu-central-1"
}

variable "instance_type" {
  default = "t2.micro"
}


#Amazon Linux 2 AMI (HVM), SSD Volume Type - ami-089b5384aac360007 (64-bit x86)
data "aws_ami" "ami_amazon2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
