output "firehose_delivery_stream_arn" {
  value = aws_kinesis_firehose_delivery_stream.kinesis_firehose_stream_logs.arn
}

output "all_data_bucket_name" {
  description = "Name of the all data S3 bucket (when backup_all_data_to_s3 is enabled)"
  value       = var.backup_all_data_to_s3 ? aws_s3_bucket.all_data[0].id : ""
}

output "all_data_bucket_arn" {
  description = "ARN of the all data S3 bucket (when backup_all_data_to_s3 is enabled)"
  value       = var.backup_all_data_to_s3 ? aws_s3_bucket.all_data[0].arn : ""
}

output "failed_bucket_name" {
  description = "Name of the failed S3 bucket"
  value       = var.backup_all_data_to_s3 ? "" : aws_s3_bucket.failed[0].id
}

output "failed_bucket_arn" {
  description = "ARN of the failed S3 bucket"
  value       = var.backup_all_data_to_s3 ? "" : aws_s3_bucket.failed[0].arn
}
