output "logs_firehose_delivery_stream_arn" {
  value = try(module.firehose_logs[0].firehose_delivery_stream_arn, "")
}

output "logs_producer_role" {
  value = try(aws_iam_role.logs_producer_role[0].arn, "")
}

output "metrics_firehose_delivery_stream_arn" {
  value = try(module.firehose_metrics[0].firehose_delivery_stream_arn, "")
}

output "metrics_producer_role" {
  value = try(aws_iam_role.metrics_producer_role[0].arn, "")
}
