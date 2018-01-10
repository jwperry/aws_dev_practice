provider "aws" {
  access_key = "${trimspace(file("../../secrets/plaintext/aws/terraform_dev_access_key"))}"
  secret_key = "${trimspace(file("../../secrets/plaintext/aws/terraform_dev_secret_key"))}"
  region = "us-west-2"
}

resource "aws_instance" "dev-practice-02-jp" {
  ami = "ami-8803e0f0"
  instance_type = "t2.micro"
  subnet_id = "subnet-3baf2473"
  vpc_security_group_ids = ["sg-d33271ae", "sg-a42c6fd9"]
  tags {
    Name = "dev-practice-02-jp",
    Owner = "JP"
  }
}
