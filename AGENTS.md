# terraform-aws-datadog-firehose

Terraform module for provisioning AWS Kinesis Firehose to stream CloudWatch logs and metrics to Datadog. Handles IAM roles, S3 buckets for failed records, KMS encryption, and optional log/metric firehoses.

## Layout

- `main.tf` — root module resources: IAM roles for logs/metrics producers, S3 bucket for failed records, KMS key, firehose module instantiation
- `variables.tf` — configurable parameters: Datadog endpoints/API key, buffering settings, retention policies, feature flags
- `outputs.tf` — exported values: firehose ARNs, IAM role ARNs
- `versions.tf` — provider requirements (AWS >= 5.0)
- `readme.md` — setup examples for connecting metrics/logs
- `modules/firehose/` — reusable Kinesis Firehose module with Datadog HTTP destination

## Required

- AWS provider >= 5.0
- Datadog API key via `datadog_access_key` variable
- Datadog endpoint URLs for logs and metrics

## Test/build

Validate syntax and plan deployments:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

## Key libraries

- AWS provider (hashicorp/aws >= 5.0) — manages IAM, S3, KMS, Firehose resources

## Maintaining this index

- Update the affected `AGENTS.md` files in the same change when paths,
  responsibilities, commands, dependencies, or conventions change.
- Keep indexes brief: record semantic entry points and non-obvious
  constraints; link to existing documentation instead of duplicating it.
- Add a directory index only when it provides useful navigation beyond its
  parent; omit generated, vendored, and fixture trees.
- Do not add `CLAUDE.md` files; Claude Code reads `AGENTS.md` natively, and
  a `CLAUDE.md` anywhere in the tree stops every `AGENTS.md` from loading.
