resource "aws_iam_role_policy" "vault_s3_kms" {
  count = var.enable_s3_backend && var.enable_s3_backend_encryption ? 1 : 0
  name  = "vault_s3_kms"
  role  = aws_iam_role.instance_role.id
  policy = element(
    concat(data.aws_iam_policy_document.vault_s3_kms.*.json, [""]),
    0,
  )
}

resource "aws_iam_role_policy" "vault_s3" {
  count = var.enable_s3_backend ? 1 : 0
  name  = "vault_s3"
  role  = aws_iam_role.instance_role.id
  policy = element(
    concat(data.aws_iam_policy_document.vault_s3.*.json, [""]),
    0,
  )
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
  path        = "/"
  role        = aws_iam_role.instance_role.name

  lifecycle {
    create_before_destroy = true
  }
}
