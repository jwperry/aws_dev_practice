provider "aws" {
  access_key = "${trimspace(file("../../secrets/plaintext/aws/terraform_dev_access_key"))}"
  secret_key = "${trimspace(file("../../secrets/plaintext/aws/terraform_dev_secret_key"))}"
  region = "us-west-2"
}

resource "aws_key_pair" "dev-practice-jp-ssh" {
  key_name = "dev-practice-jp-ssh"
  public_key = "${file("../../secrets/plaintext/ssh/dev-practice-jp.pub")}"
}

resource "aws_vpc" "dev-practice-jp-vpc" {
  cidr_block = "172.16.0.0/16"
  enable_dns_hostnames = true
  tags {
    Name = "dev-practice-jp-vpc",
    Owner = "JP"
  }
}

resource "aws_security_group" "dev-practice-jp-ssh-in" {
  name = "dev-practice-jp-ssh-in"
  description = "Allow inbound SSH traffic"
  vpc_id = "${aws_vpc.dev-practice-jp-vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "dev-practice-jp-ssh-in",
    Owner = "JP"
  }
}

resource "aws_security_group" "dev-practice-jp-vpc-transit" {
  name = "dev-practice-jp-vpc-transit"
  description = "Intra-VPC traffic rules"
  vpc_id = "${aws_vpc.dev-practice-jp-vpc.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "dev-practice-jp-vpc-transit",
    Owner = "JP"
  }
}

resource "aws_subnet" "dev-practice-jp-subnet" {
  vpc_id = "${aws_vpc.dev-practice-jp-vpc.id}"
  cidr_block = "172.16.10.0/24"
  availability_zone = "us-west-2a"
  tags {
    Name = "dev-practice-jp-subnet",
    Owner = "JP"
  }
}

resource "aws_instance" "dev-practice-jp" {
  ami = "ami-8803e0f0"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.dev-practice-jp-subnet.id}"
  availability_zone = "us-west-2a"
  vpc_security_group_ids = ["${aws_security_group.dev-practice-jp-ssh-in.id}", "${aws_security_group.dev-practice-jp-vpc-transit.id}"]
  associate_public_ip_address = "true"
  key_name = "${aws_key_pair.dev-practice-jp-ssh.id}"
  tags {
    Name = "dev-practice-jp",
    Owner = "JP"
  }
}
