terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state — all config injected via -backend-config flags in CI/CD.
  # Local dev: terraform init -backend=false (uses local state file).
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  # LocalStack endpoint override — active only in local dev
  dynamic "endpoints" {
    for_each = local.is_local_dev ? [1] : []
    content {
      dynamodb       = var.localstack_endpoint
      secretsmanager = var.localstack_endpoint
      ssm            = var.localstack_endpoint
    }
  }

  # LocalStack accepts any static credentials
  access_key = local.is_local_dev ? "test" : null
  secret_key = local.is_local_dev ? "test" : null

  skip_credentials_validation = local.is_local_dev
  skip_requesting_account_id  = local.is_local_dev
  skip_metadata_api_check     = local.is_local_dev
}
