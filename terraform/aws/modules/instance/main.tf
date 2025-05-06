variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "tailscale_auth_key" {}

provider "aws" {
  region = "us-east-1"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

# Define SSH Key
resource "aws_key_pair" "keypair" {
  key_name     = "terraform-public-key-1"
  public_key   = file(var.public_key_file)
}

resource "aws_instance" "instance" {
  ami                 = "ami-0ba992fa05aaa4a76"
  instance_type       = "t3.nano"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true
  key_name            = aws_key_pair.keypair.key_name
  user_data = templatefile("startup_script.sh", {
  tailscale_auth_key = var.tailscale_auth_key
})

  tags = {
    Name = "VirtualMachine-1"
  }
}

