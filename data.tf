data "aws_region" "current" {}

data "aws_elb" "vault_elb" {
  name = module.vault_elb.name
}
