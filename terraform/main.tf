# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

data "aws_ami" "ubuntu" {
  most_recent      = true
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]

  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

# Create a VPC to launch our instances into
resource "aws_vpc" "vpc-np" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "gw-np" {
  vpc_id = "${aws_vpc.vpc-np.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "rt-np" {
  route_table_id         = "${aws_vpc.vpc-np.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw-np.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "sub-dmz-np" {
  vpc_id                  = "${aws_vpc.vpc-np.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "sg_elb_np" {
  name        = "sg_elb_np"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.vpc-np.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "sg_web_np" {
  name        = "sg_web_np"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.vpc-np.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_elb" "elb-web-np" {
  name = "elb-web-np"

  subnets         = ["${aws_subnet.sub-dmz-np.id}"]
  security_groups = ["${aws_security_group.sg_elb_np.id}"]
  instances       = ["${aws_instance.web01_np.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

}

resource "aws_instance" "web01_np" {
  instance_type = "t2.micro"
  ami = "${data.aws_ami.ubuntu.id}"
  key_name   = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.sg_web_np.id}"]
  subnet_id = "${aws_subnet.sub-dmz-np.id}"
  user_data = "${file("terraform.sh")}"
  tags {
      Name = "web01_np"
      node_environment = "uat"
  }

  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }

}
