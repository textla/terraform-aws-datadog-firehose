variable "name" {
  description = "Name"
  type        = string
}

variable "datadog_endpoint" {
  description = "DataDog endpoint"
  type        = string
}

variable "datadog_access_key" {
  description = "DataDog access key"
  type        = string
}

variable "role_arn" {
  description = "Firehose Role ARN"
  type        = string
  default     = null
}

variable "buffering_size" {
  description = "Firehose Buffering Size"
  type        = number
  default     = 4
}

variable "buffering_interval" {
  description = "Firehose Buffering Interval"
  type        = number
  default     = 60
}

variable "content_encoding" {
  description = "Firehose Content Encoding"
  type        = string
  default     = "GZIP"
}

variable "s3_access_log_bucket" {
  description = "S3 Access Log Bucket ID"
  type        = string
}

variable "s3_retention_days" {
  description = "S3 Retention in Days"
  type        = number
  default     = 1
}

variable "backup_all_data_to_s3" {
  description = "Enable backing up all data (successful and failed) to S3. If false, only failed data will be backed up."
  type        = bool
  default     = false
}

variable "glacier_retention_days" {
  description = "Retention period for logs in Glacier storage in days. Set to 0 to disable Glacier transition and keep all logs in Standard storage."
  type        = number
  default     = 365
}
