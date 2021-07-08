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

data "template_file" "user_data_vault_cluster" {
  template = file("${path.module}/user-data-vault.sh")

  vars = {
    enable_s3_backend        = var.enable_s3_backend ? 1 : 0
    s3_bucket_region         = data.aws_region.current.name
    s3_bucket_name           = var.s3_bucket_name
    consul_cluster_tag_key   = local.consul_cluster_tag_key
    consul_cluster_tag_value = local.consul_cluster_tag_val
    ssh_keys                 = join("\n", var.ssh_keys)
    ssh_user                 = "ubuntu"
  }
}

data "template_file" "user_data_consul" {
  template = file("${path.module}/user-data-consul.sh")

  vars = {
    consul_cluster_tag_key   = local.consul_cluster_tag_key
    consul_cluster_tag_value = local.consul_cluster_tag_val
    ssh_keys                 = join("\n", var.ssh_keys)
    ssh_user                 = "ubuntu"
  }
}
