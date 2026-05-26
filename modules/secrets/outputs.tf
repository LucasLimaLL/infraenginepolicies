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

output "redis_secret_recovery_window_in_days" {
  description = "Recovery window in days for the Redis credentials secret."
  value       = aws_secretsmanager_secret.redis_credentials.recovery_window_in_days
}

output "app_tokens_recovery_window_in_days" {
  description = "Recovery window in days for the app tokens secret."
  value       = aws_secretsmanager_secret.app_tokens.recovery_window_in_days
}
