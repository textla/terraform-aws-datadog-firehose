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
  default = null
}

variable "buffering_size" {
  description = "Firehose Buffering Size"
  type        = number
  default = 4
}

variable "buffering_interval" {
  description = "Firehose Buffering Interval"
  type        = number
  default = 60
}

variable "content_encoding" {
  description = "Firehose Content Encoding"
  type        = string
  default = "GZIP"
}

variable "s3_access_log_bucket" {
  description = "S3 Access Log Bucket ID"
  type        = string
}