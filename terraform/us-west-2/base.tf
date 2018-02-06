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

resource "aws_internet_gateway" "dev-practice-jp-igw" {
  vpc_id = "${aws_vpc.dev-practice-jp-vpc.id}"

  tags {
    Name = "dev-practice-jp-igw",
    Owner = "JP"
  }
}

resource "aws_route_table" "dev-practice-jp-route-table" {
  vpc_id = "${aws_vpc.dev-practice-jp-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.dev-practice-jp-igw.id}"
  }

  tags {
    Name = "dev-practice-jp-route-table",
    Owner = "JP"
  }
}

resource "aws_main_route_table_association" "us-west-2-nat-assoc" {
  vpc_id = "${aws_vpc.dev-practice-jp-vpc.id}"
  route_table_id = "${aws_route_table.dev-practice-jp-route-table.id}"
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
  count = 5
  ami = "ami-8803e0f0"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.dev-practice-jp-subnet.id}"
  availability_zone = "us-west-2a"
  vpc_security_group_ids = ["${aws_security_group.dev-practice-jp-ssh-in.id}", "${aws_security_group.dev-practice-jp-vpc-transit.id}"]
  associate_public_ip_address = "true"
  key_name = "${aws_key_pair.dev-practice-jp-ssh.id}"
  tags {
    Name = "dev-practice-jp-0${count.index + 1}",
    Owner = "JP"
  }
  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "ubuntu"
      private_key         = "${file("~/.ssh/dev-practice-jp-ssh")}"
    }
    inline = [
      "sudo apt-get update",
      "DEBIAN_FRONTEND=noninteractive sudo -E apt-get -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confnew' upgrade",
      "sudo apt update",
      "sudo apt install python -y",
      "echo dev-practice-jp-0${count.index + 1} | sudo tee /etc/hostname > /dev/null"
    ]
  }
}