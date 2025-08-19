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
    enabled  = true
    key_type = "CUSTOMER_MANAGED_CMK"
    key_arn  = aws_kms_key.stream.arn
  }

  http_endpoint_configuration {
    url                = var.datadog_endpoint
    name               = "Datadog"
    access_key         = var.datadog_access_key
    buffering_size     = var.buffering_size
    buffering_interval = var.buffering_interval
    role_arn           = var.role_arn
    s3_backup_mode     = var.backup_all_logs_to_s3 ? "AllData" : "FailedDataOnly"

    s3_configuration {
      role_arn            = var.role_arn
      bucket_arn          = var.backup_all_logs_to_s3 ? aws_s3_bucket.all_logs[0].arn : aws_s3_bucket.failed.arn
      prefix              = var.backup_all_logs_to_s3 ? "successful/" : null
      error_output_prefix = var.backup_all_logs_to_s3 ? "failed/" : null
    }

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
    id     = "failed_logs_lifecycle"
    status = "Enabled"

    filter {}

    # Conditional Glacier transition for failed logs bucket
    dynamic "transition" {
      for_each = var.glacier_retention_days > 0 ? [1] : []
      content {
        days          = var.s3_retention_days
        storage_class = "GLACIER"
      }
    }

    dynamic "noncurrent_version_transition" {
      for_each = var.glacier_retention_days > 0 ? [1] : []
      content {
        noncurrent_days = var.s3_retention_days
        storage_class   = "GLACIER"
      }
    }

    noncurrent_version_expiration {
      noncurrent_days = var.glacier_retention_days > 0 ? var.glacier_retention_days : var.s3_retention_days
    }

    expiration {
      days = var.glacier_retention_days > 0 ? var.glacier_retention_days : var.s3_retention_days
    }
  }
}

resource "aws_s3_bucket_logging" "failed" {
  bucket        = aws_s3_bucket.failed.id
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

# All logs S3 bucket (when backup_all_logs_to_s3 is enabled)
resource "aws_kms_key" "all_logs" {
  count               = var.backup_all_logs_to_s3 ? 1 : 0
  description         = "${var.name}-all-logs"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.all_logs[0].json
}

data "aws_iam_policy_document" "all_logs" {
  count = var.backup_all_logs_to_s3 ? 1 : 0
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

resource "aws_s3_bucket" "all_logs" {
  count  = var.backup_all_logs_to_s3 ? 1 : 0
  bucket = "${data.aws_caller_identity.current.account_id}-${var.name}"
}

resource "aws_s3_bucket_lifecycle_configuration" "all_logs" {
  count  = var.backup_all_logs_to_s3 ? 1 : 0
  bucket = aws_s3_bucket.all_logs[0].id

  # Rule for successful logs
  rule {
    id     = "successful_logs"
    status = "Enabled"

    filter {
      prefix = "successful/"
    }

    # Conditional Glacier transition for successful logs
    dynamic "transition" {
      for_each = var.glacier_retention_days > 0 ? [1] : []
      content {
        days          = 1
        storage_class = "GLACIER"
      }
    }

    dynamic "noncurrent_version_transition" {
      for_each = var.glacier_retention_days > 0 ? [1] : []
      content {
        noncurrent_days = 1
        storage_class   = "GLACIER"
      }
    }

    noncurrent_version_expiration {
      noncurrent_days = var.glacier_retention_days > 0 ? var.glacier_retention_days : var.s3_retention_days
    }

    expiration {
      days = var.glacier_retention_days > 0 ? var.glacier_retention_days : var.s3_retention_days
    }
  }

  # Rule for failed logs - two-stage lifecycle
  rule {
    id     = "failed_logs_two_stage"
    status = "Enabled"

    filter {
      prefix = "failed/"
    }

    # Conditional Glacier transition for failed logs after investigation period
    dynamic "transition" {
      for_each = var.glacier_retention_days > 0 ? [1] : []
      content {
        days          = var.s3_retention_days
        storage_class = "GLACIER"
      }
    }

    dynamic "noncurrent_version_transition" {
      for_each = var.glacier_retention_days > 0 ? [1] : []
      content {
        noncurrent_days = var.s3_retention_days
        storage_class   = "GLACIER"
      }
    }

    noncurrent_version_expiration {
      noncurrent_days = var.glacier_retention_days > 0 ? var.glacier_retention_days : var.s3_retention_days
    }

    expiration {
      days = var.glacier_retention_days > 0 ? var.glacier_retention_days : var.s3_retention_days
    }
  }
}

resource "aws_s3_bucket_logging" "all_logs" {
  count         = var.backup_all_logs_to_s3 ? 1 : 0
  bucket        = aws_s3_bucket.all_logs[0].id
  target_bucket = var.s3_access_log_bucket
  target_prefix = "all-logs-access/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "all_logs" {
  count  = var.backup_all_logs_to_s3 ? 1 : 0
  bucket = aws_s3_bucket.all_logs[0].bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.all_logs[0].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "all_logs" {
  count  = var.backup_all_logs_to_s3 ? 1 : 0
  bucket = aws_s3_bucket.all_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_versioning" "all_logs" {
  count  = var.backup_all_logs_to_s3 ? 1 : 0
  bucket = aws_s3_bucket.all_logs[0].id
  versioning_configuration {
    status = "Enabled"
  }
}
