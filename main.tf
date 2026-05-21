# ─────────────────────────────────────────────────────────────────────────────
# infraenginepolicies — Root Module
#
# Composes the five sub-modules that form the AWS foundation layer.
# Networking and API Gateway are gated behind feature flags so the same
# code runs against LocalStack (local dev) and real AWS (staging/prod)
# without changes.
# ─────────────────────────────────────────────────────────────────────────────

# ── 1. DynamoDB ───────────────────────────────────────────────────────────────
# Source of truth for all rule policies. Always created (local + prod).
# Partition Key: scenario (S) | Sort Key: prioridade (N)
# No business items are seeded here — that is the responsibility of
# dataenginepolicies via Terraform data sources.

module "dynamodb" {
  source = "./modules/dynamodb"

  name_prefix = local.name_prefix
  tags        = local.common_tags
}

# ── 2. Secrets Manager ────────────────────────────────────────────────────────
# Stores Redis credentials and static B2B API tokens.
# Always created (local: LocalStack emulation | prod: real AWS).

module "secrets" {
  source = "./modules/secrets"

  name_prefix    = local.name_prefix
  redis_host     = var.redis_host
  redis_port     = var.redis_port
  redis_password = var.redis_password
  tags           = local.common_tags
}

# ── 3. SSM Parameter Store ───────────────────────────────────────────────────
# Stores behavioural parameters consumed by Spring Boot at startup:
#   - default-timeout-ms (global fallback, overridden per rule in DynamoDB)
#   - app-port, spel-cache-max-size, spel-cache-expire-minutes
# Always created (local: LocalStack emulation | prod: real AWS).

module "ssm" {
  source = "./modules/ssm"

  name_prefix        = local.name_prefix
  default_timeout_ms = var.default_timeout_ms
  app_port           = var.app_port
  tags               = local.common_tags
}

# ── 4. Networking ─────────────────────────────────────────────────────────────
# VPC, public/private subnets, IGW, route tables, and Security Groups
# for ECS Fargate tasks and ElastiCache Redis.
# DISABLED for local dev (LocalStack Community does not emulate VPC/EC2).

module "networking" {
  source = "./modules/networking"
  count  = var.create_network_resources ? 1 : 0

  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  tags               = local.common_tags
}

# ── 5. API Gateway ────────────────────────────────────────────────────────────
# HTTP API v2 with route ANY /v1/motor/{proxy+} → Spring Boot backend.
# DISABLED for local dev (LocalStack Community does not emulate API Gateway).

module "api_gateway" {
  source = "./modules/api_gateway"
  count  = var.create_api_gateway ? 1 : 0

  name_prefix     = local.name_prefix
  app_backend_url = var.app_backend_url
  tags            = local.common_tags
}
