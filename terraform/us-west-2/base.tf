provider "aws" {
  access_key = "${trimspace(file("../../secrets/plaintext/aws/terraform_dev_access_key"))}"
  secret_key = "${trimspace(file("../../secrets/plaintext/aws/terraform_dev_secret_key"))}"
  region = "us-west-2"
}

resource "aws_network_interface" "dev-practice-02-jp-network-interface" {
  subnet_id = "subnet-3baf2473"
  private_ips = ["198.18.21.0"]
  tags {
    Name = "dev-practice-02-jp-network-interface",
    Owner = "JP"
  }
}

resource "aws_instance" "dev-practice-02-jp" {
  ami = "ami-8803e0f0"
  instance_type = "t2.micro"
  network_interface {
    network_interface_id = "eni-f69184c6"
    device_index = 0
  }
  tags {
    Name = "dev-practice-02-jp",
    Owner = "JP"
  }
}
