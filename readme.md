### Setup
```terraform
data "aws_secretsmanager_secret" "datadog_api_key" {
  name = "datadog/api_key"
}

data "aws_secretsmanager_secret_version" "datadog_api_key" {
  secret_id = data.aws_secretsmanager_secret.datadog_api_key.id
}

module "datadog" {
  source = "nolotz/datadog-firehose/aws"

  datadog_access_key = data.aws_secretsmanager_secret_version.datadog_api_key.secret_string
  datadog_logs_endpoint = "https://aws-kinesis-http-intake.logs.datadoghq.eu/v1/input"
  datadog_metrics_endpoint = "https://awsmetrics-intake.datadoghq.eu/v1/input"
}
```

### Connect Metrics
```terraform
resource "aws_cloudwatch_metric_stream" "aws_metrics" {
  name          = "aws-metrics"
  output_format = "opentelemetry0.7"
  role_arn      = module.datadog.metrics_producer_role
  firehose_arn  = module.datadog.metrics_firehose_delivery_stream_arn
}
````

### Connect Logs
```terraform
resource "aws_cloudwatch_log_subscription_filter" "datadog_subscription" {
  name            = "datadog_subscription"
  log_group_name  = "logGroup"
  filter_pattern  = ""
  distribution    = "Random"
  role_arn        = module.datadog.logs_producer_role
  destination_arn = module.datadog.logs_firehose_delivery_stream_arn
}
````