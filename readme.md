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
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.67.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_firehose_logs"></a> [firehose\_logs](#module\_firehose\_logs) | ./modules/firehose | n/a |
| <a name="module_firehose_metrics"></a> [firehose\_metrics](#module\_firehose\_metrics) | ./modules/firehose | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_role.firehose_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.logs_producer_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.metrics_producer_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.logs_producer_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.metrics_producer_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_key.failed_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.failed_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.failed_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.failed_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_public_access_block.failed_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.failed_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.failed_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.failed_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.firehose_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.logs_producer_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.logs_producer_role_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.metrics_producer_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.metrics_producer_role_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_content_encoding"></a> [content\_encoding](#input\_content\_encoding) | Firehose Content Encoding | `string` | `"GZIP"` | no |
| <a name="input_datadog_access_key"></a> [datadog\_access\_key](#input\_datadog\_access\_key) | DataDog access key | `string` | n/a | yes |
| <a name="input_datadog_logs_endpoint"></a> [datadog\_logs\_endpoint](#input\_datadog\_logs\_endpoint) | DataDog endpoint | `string` | n/a | yes |
| <a name="input_datadog_metrics_endpoint"></a> [datadog\_metrics\_endpoint](#input\_datadog\_metrics\_endpoint) | DataDog endpoint | `string` | n/a | yes |
| <a name="input_firehose_logs"></a> [firehose\_logs](#input\_firehose\_logs) | Firehose Logs Enabled | `bool` | `true` | no |
| <a name="input_firehose_logs_buffering_interval"></a> [firehose\_logs\_buffering\_interval](#input\_firehose\_logs\_buffering\_interval) | Firehose Buffering Interval | `number` | `60` | no |
| <a name="input_firehose_logs_buffering_size"></a> [firehose\_logs\_buffering\_size](#input\_firehose\_logs\_buffering\_size) | Firehose Buffering Size | `number` | `4` | no |
| <a name="input_firehose_logs_encryption_key_arn"></a> [firehose\_logs\_encryption\_key\_arn](#input\_firehose\_logs\_encryption\_key\_arn) | Deprecated, unused: the module creates its own KMS keys. Kept so existing callers don't break. SSE Key ARN | `string` | `null` | no |
| <a name="input_firehose_logs_s3_encryption_key_arn"></a> [firehose\_logs\_s3\_encryption\_key\_arn](#input\_firehose\_logs\_s3\_encryption\_key\_arn) | Deprecated, unused: the module creates its own KMS keys. Kept so existing callers don't break. S3 Failed Bucket SSE Key ARN | `string` | `null` | no |
| <a name="input_firehose_metrics"></a> [firehose\_metrics](#input\_firehose\_metrics) | Firehose Metrics Enabled | `bool` | `true` | no |
| <a name="input_firehose_metrics_buffering_interval"></a> [firehose\_metrics\_buffering\_interval](#input\_firehose\_metrics\_buffering\_interval) | Firehose Buffering Interval | `number` | `60` | no |
| <a name="input_firehose_metrics_buffering_size"></a> [firehose\_metrics\_buffering\_size](#input\_firehose\_metrics\_buffering\_size) | Firehose Buffering Size | `number` | `4` | no |
| <a name="input_firehose_metrics_encryption_key_arn"></a> [firehose\_metrics\_encryption\_key\_arn](#input\_firehose\_metrics\_encryption\_key\_arn) | Deprecated, unused: the module creates its own KMS keys. Kept so existing callers don't break. SSE Key ARN | `string` | `null` | no |
| <a name="input_firehose_metrics_s3_encryption_key_arn"></a> [firehose\_metrics\_s3\_encryption\_key\_arn](#input\_firehose\_metrics\_s3\_encryption\_key\_arn) | Deprecated, unused: the module creates its own KMS keys. Kept so existing callers don't break. S3 Failed Bucket SSE Key ARN | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name | `string` | `"datadog-firehose"` | no |
| <a name="input_s3_access_logs_retention_days"></a> [s3\_access\_logs\_retention\_days](#input\_s3\_access\_logs\_retention\_days) | S3 Failed Buckets Access Logs Retention in Days | `number` | `1` | no |
| <a name="input_s3_logs_failed_retention_days"></a> [s3\_logs\_failed\_retention\_days](#input\_s3\_logs\_failed\_retention\_days) | S3 Logs Failed Bucket Retention in Days | `number` | `14` | no |
| <a name="input_s3_metrics_failed_retention_days"></a> [s3\_metrics\_failed\_retention\_days](#input\_s3\_metrics\_failed\_retention\_days) | S3 Metrics Failed Bucket Retention in Days | `number` | `14` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_logs_firehose_delivery_stream_arn"></a> [logs\_firehose\_delivery\_stream\_arn](#output\_logs\_firehose\_delivery\_stream\_arn) | n/a |
| <a name="output_logs_producer_role"></a> [logs\_producer\_role](#output\_logs\_producer\_role) | n/a |
| <a name="output_metrics_firehose_delivery_stream_arn"></a> [metrics\_firehose\_delivery\_stream\_arn](#output\_metrics\_firehose\_delivery\_stream\_arn) | n/a |
| <a name="output_metrics_producer_role"></a> [metrics\_producer\_role](#output\_metrics\_producer\_role) | n/a |
<!-- END_TF_DOCS -->
