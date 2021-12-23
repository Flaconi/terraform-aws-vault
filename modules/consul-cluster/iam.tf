data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

module "iam_policies" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-iam-policies?ref=v0.11.0"

  iam_role_id = aws_iam_role.instance_role.id
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = var.cluster_name
  assume_role_policy = data.aws_iam_policy_document.instance_role.json

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = var.cluster_name
  path        = var.instance_profile_path
  role        = aws_iam_role.instance_role.name

  lifecycle {
    create_before_destroy = true
  }
}
