output "firehose_delivery_stream_arn" {
  value = aws_kinesis_firehose_delivery_stream.kinesis_firehose_stream_logs.arn
}