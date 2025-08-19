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

output "all_logs_bucket_name" {
  description = "Name of the all logs S3 bucket (when backup_all_logs_to_s3 is enabled)"
  value       = var.firehose_logs ? module.firehose_logs[0].all_logs_bucket_name : ""
}

output "all_logs_bucket_arn" {
  description = "ARN of the all logs S3 bucket (when backup_all_logs_to_s3 is enabled)"
  value       = var.firehose_logs ? module.firehose_logs[0].all_logs_bucket_arn : ""
}

output "failed_access_bucket_name" {
  description = "Name of the failed access S3 bucket"
  value       = aws_s3_bucket.failed_access.id
}

output "failed_access_bucket_arn" {
  description = "ARN of the failed access S3 bucket"
  value       = aws_s3_bucket.failed_access.arn
}

output "logs_failed_bucket_name" {
  description = "Name of the logs failed S3 bucket"
  value       = var.firehose_logs ? module.firehose_logs[0].failed_bucket_name : ""
}

output "logs_failed_bucket_arn" {
  description = "ARN of the logs failed S3 bucket"
  value       = var.firehose_logs ? module.firehose_logs[0].failed_bucket_arn : ""
}

output "metrics_failed_bucket_name" {
  description = "Name of the metrics failed S3 bucket"
  value       = var.firehose_metrics ? module.firehose_metrics[0].failed_bucket_name : ""
}

output "metrics_failed_bucket_arn" {
  description = "ARN of the metrics failed S3 bucket"
  value       = var.firehose_metrics ? module.firehose_metrics[0].failed_bucket_arn : ""
}
