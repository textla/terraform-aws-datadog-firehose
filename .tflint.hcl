# tflint configuration delivered by textla/cr-terraform-module.
# The terraform_tflint hook passes this file with --config, and script/lint
# runs tflint --recursive with it.

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.49.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
