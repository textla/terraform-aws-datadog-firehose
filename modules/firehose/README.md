# firehose

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

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_kinesis_firehose_delivery_stream.kinesis_firehose_stream_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_kms_key.failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_public_access_block.failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_buffering_interval"></a> [buffering\_interval](#input\_buffering\_interval) | Firehose Buffering Interval | `number` | `60` | no |
| <a name="input_buffering_size"></a> [buffering\_size](#input\_buffering\_size) | Firehose Buffering Size | `number` | `4` | no |
| <a name="input_content_encoding"></a> [content\_encoding](#input\_content\_encoding) | Firehose Content Encoding | `string` | `"GZIP"` | no |
| <a name="input_datadog_access_key"></a> [datadog\_access\_key](#input\_datadog\_access\_key) | DataDog access key | `string` | n/a | yes |
| <a name="input_datadog_endpoint"></a> [datadog\_endpoint](#input\_datadog\_endpoint) | DataDog endpoint | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name | `string` | n/a | yes |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | Firehose Role ARN | `string` | `null` | no |
| <a name="input_s3_access_log_bucket"></a> [s3\_access\_log\_bucket](#input\_s3\_access\_log\_bucket) | S3 Access Log Bucket ID | `string` | n/a | yes |
| <a name="input_s3_retention_days"></a> [s3\_retention\_days](#input\_s3\_retention\_days) | S3 Retention in Days | `number` | `1` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_firehose_delivery_stream_arn"></a> [firehose\_delivery\_stream\_arn](#output\_firehose\_delivery\_stream\_arn) | n/a |
<!-- END_TF_DOCS -->
