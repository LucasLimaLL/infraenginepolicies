# ─────────────────────────────────────────────────────────────────────────────
# Root Outputs
#
# These values are consumed by dataenginepolicies via Terraform data sources
# at apply time — no hardcoded names or ARNs between repositories.
# ─────────────────────────────────────────────────────────────────────────────

# ── DynamoDB ──────────────────────────────────────────────────────────────────

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table. Consumed by dataenginepolicies via aws_dynamodb_table data source."
  value       = module.dynamodb.table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table."
  value       = module.dynamodb.table_arn
}

output "dynamodb_hash_key" {
  description = "Partition key attribute name (scenario)."
  value       = module.dynamodb.hash_key
}

output "dynamodb_range_key" {
  description = "Sort key attribute name (prioridade)."
  value       = module.dynamodb.range_key
}

output "dynamodb_billing_mode" {
  description = "Billing mode (PAY_PER_REQUEST for on-demand)."
  value       = module.dynamodb.billing_mode
}

output "dynamodb_pitr_enabled" {
  description = "Point-in-Time Recovery enabled flag."
  value       = module.dynamodb.pitr_enabled
}

output "dynamodb_ttl_attribute_name" {
  description = "TTL attribute name (expiracao)."
  value       = module.dynamodb.ttl_attribute_name
}

output "dynamodb_ttl_enabled" {
  description = "TTL enabled flag."
  value       = module.dynamodb.ttl_enabled
}

output "name_prefix" {
  description = "Composed name prefix (project-environment) used for resource naming."
  value       = local.name_prefix
}

output "secrets_redis_name" {
  description = "Name of the Redis credentials secret."
  value       = module.secrets.redis_secret_name
}

output "secrets_app_tokens_name" {
  description = "Name of the app tokens secret."
  value       = module.secrets.app_tokens_secret_name
}

output "secrets_redis_recovery_window_in_days" {
  description = "Recovery window in days for the Redis credentials secret."
  value       = module.secrets.redis_secret_recovery_window_in_days
}

output "ssm_default_timeout_ms_value" {
  description = "Stored timeout value (string form)."
  value       = module.ssm.default_timeout_ms_value
  sensitive   = true
}

output "ssm_app_port_value" {
  description = "Stored app port value (string form)."
  value       = module.ssm.app_port_value
  sensitive   = true
}

# ── Secrets Manager ───────────────────────────────────────────────────────────

output "secrets_redis_arn" {
  description = "ARN of the Redis credentials secret (consumed by appenginepolicies at runtime)."
  value       = module.secrets.redis_secret_arn
}

output "secrets_app_tokens_arn" {
  description = "ARN of the static B2B API tokens secret."
  value       = module.secrets.app_tokens_secret_arn
}

# ── SSM Parameter Store ───────────────────────────────────────────────────────

output "ssm_default_timeout_ms_name" {
  description = "SSM parameter path for the global HTTP timeout fallback."
  value       = module.ssm.timeout_parameter_name
}

output "ssm_app_port_name" {
  description = "SSM parameter path for the Spring Boot application port."
  value       = module.ssm.app_port_parameter_name
}

output "ssm_spel_cache_max_size_name" {
  description = "SSM parameter path for the Caffeine SpEL cache max size."
  value       = module.ssm.spel_cache_max_size_parameter_name
}

output "ssm_spel_cache_expire_minutes_name" {
  description = "SSM parameter path for the Caffeine SpEL cache TTL."
  value       = module.ssm.spel_cache_expire_minutes_parameter_name
}

# ── API Gateway ───────────────────────────────────────────────────────────────

output "api_gateway_invoke_url" {
  description = "HTTP API Gateway invoke URL. 'N/A' when create_api_gateway = false (local dev)."
  value       = var.create_api_gateway ? module.api_gateway[0].invoke_url : "N/A (local dev)"
}

output "api_gateway_id" {
  description = "HTTP API Gateway ID."
  value       = var.create_api_gateway ? module.api_gateway[0].api_id : "N/A (local dev)"
}

# ── Networking ────────────────────────────────────────────────────────────────

output "vpc_id" {
  description = "VPC ID. 'N/A' when create_network_resources = false (local dev)."
  value       = var.create_network_resources ? module.networking[0].vpc_id : "N/A (local dev)"
}

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = var.create_network_resources ? module.networking[0].public_subnet_ids : []
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value       = var.create_network_resources ? module.networking[0].private_subnet_ids : []
}

output "fargate_security_group_id" {
  description = "Security group ID for ECS Fargate tasks."
  value       = var.create_network_resources ? module.networking[0].fargate_sg_id : "N/A (local dev)"
}

output "redis_security_group_id" {
  description = "Security group ID for ElastiCache Redis."
  value       = var.create_network_resources ? module.networking[0].redis_sg_id : "N/A (local dev)"
}
