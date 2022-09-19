resource "aws_iam_role" "firehose_role" {
  name        = "${var.name}-firehose-role"
  description = "IAM Role for Kinesis Firehose"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
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

module "firehose_logs" {
  source = "./modules/firehose"
  name = "${var.name}-logs"
  count = var.firehose_logs ? 1 : 0

  datadog_endpoint = var.datadog_logs_endpoint
  datadog_access_key = var.datadog_access_key

  buffering_interval = var.firehose_logs_buffering_interval
  buffering_size = var.firehose_logs_buffering_size
  content_encoding = var.content_encoding

  role_arn = aws_iam_role.firehose_role.arn
}

module "firehose_metrics" {
  source = "./modules/firehose"
  name = "${var.name}-metrics"
  count = var.firehose_metrics ? 1 : 0

  datadog_endpoint = var.datadog_metrics_endpoint
  datadog_access_key = var.datadog_access_key

  buffering_interval = var.firehose_metrics_buffering_interval
  buffering_size = var.firehose_metrics_buffering_size
  content_encoding = var.content_encoding

  role_arn = aws_iam_role.firehose_role.arn
}
