provider "aws" {
  access_key = "../../secrets/plaintext/aws/terraform_dev_access_key"
  secret_key = "../../secrets/plaintext/aws/terraform_dev_secret_key"
  region = "us-west-2"
}

resource "aws_instance" "dev-practice-02-jp" {
  ami = "ami-8803e0f0"
  instance_type = "t2.micro"
  network_interface {
    network_interface_id = "eni-f69184c6"
    device_index = 0
  }
  tags {
    Name = "dev-practice-02-jp"
  }
}
