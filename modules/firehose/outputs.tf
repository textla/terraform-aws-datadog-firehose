output "firehose_delivery_stream_arn" {
  value = aws_kinesis_firehose_delivery_stream.kinesis_firehose_stream_logs.arn
}

output "all_logs_bucket_name" {
  description = "Name of the all logs S3 bucket (when backup_all_logs_to_s3 is enabled)"
  value       = var.backup_all_logs_to_s3 ? aws_s3_bucket.all_logs[0].id : ""
}

output "all_logs_bucket_arn" {
  description = "ARN of the all logs S3 bucket (when backup_all_logs_to_s3 is enabled)"
  value       = var.backup_all_logs_to_s3 ? aws_s3_bucket.all_logs[0].arn : ""
}

output "failed_bucket_name" {
  description = "Name of the failed S3 bucket"
  value       = aws_s3_bucket.failed.id
}

output "failed_bucket_arn" {
  description = "ARN of the failed S3 bucket"
  value       = aws_s3_bucket.failed.arn
}
