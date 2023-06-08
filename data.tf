data "aws_region" "current" {}

data "aws_ami" "vault_consul" {
  most_recent = true

  owners = [var.ami_owner]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = var.ami_name_filter
  }
}

data "aws_elb" "vault_elb" {
  name = module.vault_elb.name
}
