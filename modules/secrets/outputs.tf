output "redis_secret_arn" {
  description = "ARN of the Redis credentials secret."
  value       = aws_secretsmanager_secret.redis_credentials.arn
}

output "redis_secret_name" {
  description = "Name of the Redis credentials secret (for SDK lookup by name)."
  value       = aws_secretsmanager_secret.redis_credentials.name
}

output "app_tokens_secret_arn" {
  description = "ARN of the B2B API tokens secret."
  value       = aws_secretsmanager_secret.app_tokens.arn
}

output "app_tokens_secret_name" {
  description = "Name of the B2B API tokens secret."
  value       = aws_secretsmanager_secret.app_tokens.name
}
