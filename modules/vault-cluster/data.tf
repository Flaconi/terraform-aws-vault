data "aws_iam_policy_document" "vault_s3" {
  count = var.enable_s3_backend ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["s3:*"]

    resources = [
      data.aws_s3_bucket.vault_storage[0].arn,
      "${data.aws_s3_bucket.vault_storage[0].arn}/*",
    ]
  }
}

data "aws_s3_bucket" "vault_storage" {
  count  = var.enable_s3_backend ? 1 : 0
  bucket = var.s3_bucket_name
}

data "aws_iam_policy_document" "vault_s3_kms" {
  count = var.enable_s3_backend && var.enable_s3_backend_encryption ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]

    resources = [
      data.aws_kms_key.vault_encryption[0].arn,
    ]
  }
}

data "aws_kms_key" "vault_encryption" {
  count  = var.enable_s3_backend && var.enable_s3_backend_encryption ? 1 : 0
  key_id = var.kms_alias_name
}

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
