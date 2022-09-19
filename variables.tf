variable "name" {
  description = "Name"
  type        = string
  default = "datadog-firehose"
}

variable "datadog_access_key" {
  description = "DataDog access key"
  type        = string
}

variable "datadog_metrics_endpoint" {
  description = "DataDog endpoint"
  type        = string
}

variable "datadog_logs_endpoint" {
  description = "DataDog endpoint"
  type        = string
}

variable "content_encoding" {
  description = "Firehose Content Encoding"
  type        = string
  default = "GZIP"
}

variable "firehose_logs" {
  description = "Firehose Logs Enabled"
  type = bool
  default = true
}

variable "firehose_logs_encryption_key_arn" {
  description = "SSE Key ARN"
  type        = string
  default = null
}

variable "firehose_logs_buffering_size" {
  description = "Firehose Buffering Size"
  type        = number
  default = 4
}

variable "firehose_logs_buffering_interval" {
  description = "Firehose Buffering Interval"
  type        = number
  default = 60
}

variable "firehose_logs_s3_encryption_key_arn" {
  description = "S3 Failed Bucket SSE Key ARN"
  type        = string
  default = null
}

variable "firehose_metrics" {
  description = "Firehose Metrics Enabled"
  type = bool
  default = true
}

variable "firehose_metrics_encryption_key_arn" {
  description = "SSE Key ARN"
  type        = string
  default = null
}

variable "firehose_metrics_buffering_size" {
  description = "Firehose Buffering Size"
  type        = number
  default = 4
}

variable "firehose_metrics_buffering_interval" {
  description = "Firehose Buffering Interval"
  type        = number
  default = 60
}

variable "firehose_metrics_s3_encryption_key_arn" {
  description = "S3 Failed Bucket SSE Key ARN"
  type        = string
  default = null
}
