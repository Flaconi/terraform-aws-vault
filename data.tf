data "aws_region" "current" {}

data "aws_ami" "vault_consul" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = ["flaconi/devops/custome/vault-consul-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_elb" "vault_elb" {
  name = module.vault_elb.name
}
