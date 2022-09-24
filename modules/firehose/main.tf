data "aws_caller_identity" "current" {}

resource "aws_kms_key" "stream" {
  description         = "${var.name}-stream"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.stream.json
}

data "aws_iam_policy_document" "stream" {
  statement {
    sid = "CMKOwnerPolicy"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose_stream_logs" {
  name        = var.name
  destination = "http_endpoint"

  server_side_encryption {
    enabled = true
    key_type = "CUSTOMER_MANAGED_CMK"
    key_arn = aws_kms_key.stream.arn
  }

  s3_configuration {
    role_arn   = var.role_arn
    bucket_arn = aws_s3_bucket.failed.arn
  }

  http_endpoint_configuration {
    url                = var.datadog_endpoint
    name               = "Datadog"
    access_key         = var.datadog_access_key
    buffering_size     = var.buffering_size
    buffering_interval = var.buffering_interval
    role_arn           = var.role_arn
    s3_backup_mode     = "FailedDataOnly"

    request_configuration {
      content_encoding = var.content_encoding
    }
  }
}

resource "aws_kms_key" "failed" {
  description         = "${var.name}-failed"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.failed.json
}

data "aws_iam_policy_document" "failed" {
  statement {
    sid = "CMKOwnerPolicy"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }
}

resource "aws_s3_bucket" "failed" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.name}-failed"
}

resource "aws_s3_bucket_acl" "failed" {
  bucket = aws_s3_bucket.failed.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "failed" {
  bucket = aws_s3_bucket.failed.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.failed.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "failed" {
  bucket = aws_s3_bucket.failed.id

  rule {
    id     = "delete"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.s3_retention_days
    }

    expiration {
      days = var.s3_retention_days
    }
  }
}

resource "aws_s3_bucket_logging" "failed" {
  bucket = aws_s3_bucket.failed.id
  target_bucket = var.s3_access_log_bucket
  target_prefix = "logs/"
}

resource "aws_s3_bucket_versioning" "failed" {
  bucket = aws_s3_bucket.failed.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "failed" {
  bucket = aws_s3_bucket.failed.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
