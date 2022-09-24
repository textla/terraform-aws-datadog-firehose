data "aws_iam_policy_document" "firehose_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "firehose_role" {
  name        = "${var.name}-firehose-role"
  description = "IAM Role for Kinesis Firehose"

  assume_role_policy = data.aws_iam_policy_document.firehose_role.json
}

data "aws_region" "current" {}

# Logs Producer
data "aws_iam_policy_document" "logs_producer_role" {
  statement {
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]
    resources = [
      try(module.firehose_logs[0].firehose_delivery_stream_arn, ""),
    ]
  }
}

data "aws_iam_policy_document" "logs_producer_role_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "logs_producer_role" {
  count = var.firehose_logs ? 1 : 0
  name               = "${var.name}-logs-producer-role"
  assume_role_policy = data.aws_iam_policy_document.logs_producer_role_assume.json
}

resource "aws_iam_role_policy" "logs_producer_role" {
  count = var.firehose_logs ? 1 : 0
  name   = "${var.name}-logs-producer-role"
  role   = try(aws_iam_role.logs_producer_role[0].name, "")
  policy = data.aws_iam_policy_document.logs_producer_role.json
}

# Metrics Producer
data "aws_iam_policy_document" "metrics_producer_role" {

  statement {
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch"
    ]
    resources = [
      try(module.firehose_metrics[0].firehose_delivery_stream_arn, ""),
    ]
  }
}

data "aws_iam_policy_document" "metrics_producer_role_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["streams.metrics.cloudwatch.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "metrics_producer_role" {
  count = var.firehose_metrics ? 1 : 0
  name               = "${var.name}-metrics-producer-role"
  assume_role_policy = data.aws_iam_policy_document.metrics_producer_role_assume.json
}

resource "aws_iam_role_policy" "metrics_producer_role" {
  count = var.firehose_metrics ? 1 : 0
  name   = "${var.name}-metrics-producer-role"
  role   = try(aws_iam_role.metrics_producer_role[0].name, "")
  policy = data.aws_iam_policy_document.metrics_producer_role.json
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "failed_access" {
  description         = "${var.name}-failed"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.failed_access.json
}

data "aws_iam_policy_document" "failed_access" {
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

resource "aws_s3_bucket" "failed_access" {
  bucket = "${data.aws_caller_identity.current.account_id}-${var.name}-failed-access"
}

resource "aws_s3_bucket_lifecycle_configuration" "failed_access" {
  bucket = aws_s3_bucket.failed_access.id

  rule {
    id     = "delete"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.s3_access_logs_retention_days
    }

    expiration {
      days = var.s3_access_logs_retention_days
    }
  }
}


resource "aws_s3_bucket_logging" "failed_access" {
  bucket = aws_s3_bucket.failed_access.id
  target_bucket = aws_s3_bucket.failed_access.id
  target_prefix = "logs/"
}

resource "aws_s3_bucket_acl" "failed_access" {
  bucket = aws_s3_bucket.failed_access.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "failed_access" {
  bucket = aws_s3_bucket.failed_access.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.failed_access.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "failed_access" {
  bucket = aws_s3_bucket.failed_access.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_versioning" "failed_access" {
  bucket = aws_s3_bucket.failed_access.id
  versioning_configuration {
    status = "Enabled"
  }
}

module "firehose_logs" {
  source = "./modules/firehose"
  name = "${var.name}-logs"
  count = var.firehose_logs ? 1 : 0

  datadog_endpoint = var.datadog_logs_endpoint
  datadog_access_key = var.datadog_access_key

  s3_access_log_bucket = aws_s3_bucket.failed_access.id

  buffering_interval = var.firehose_logs_buffering_interval
  buffering_size = var.firehose_logs_buffering_size
  content_encoding = var.content_encoding

  role_arn = aws_iam_role.firehose_role.arn

  s3_retention_days = var.s3_logs_failed_retention_days
}

module "firehose_metrics" {
  source = "./modules/firehose"
  name = "${var.name}-metrics"
  count = var.firehose_metrics ? 1 : 0

  datadog_endpoint = var.datadog_metrics_endpoint
  datadog_access_key = var.datadog_access_key

  s3_access_log_bucket = aws_s3_bucket.failed_access.id

  buffering_interval = var.firehose_metrics_buffering_interval
  buffering_size = var.firehose_metrics_buffering_size
  content_encoding = var.content_encoding

  role_arn = aws_iam_role.firehose_role.arn
  s3_retention_days = var.s3_metrics_failed_retention_days
}
