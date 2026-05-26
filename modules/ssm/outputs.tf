output "timeout_parameter_name" {
  description = "SSM path for the global HTTP timeout parameter."
  value       = aws_ssm_parameter.default_timeout_ms.name
}

output "app_port_parameter_name" {
  description = "SSM path for the Spring Boot application port."
  value       = aws_ssm_parameter.app_port.name
}

output "spel_cache_max_size_parameter_name" {
  description = "SSM path for the Caffeine SpEL cache max size."
  value       = aws_ssm_parameter.spel_cache_max_size.name
}

output "spel_cache_expire_minutes_parameter_name" {
  description = "SSM path for the Caffeine SpEL cache TTL."
  value       = aws_ssm_parameter.spel_cache_expire_minutes.name
}

output "default_timeout_ms_value" {
  description = "Stored value of the default timeout parameter (as string)."
  value       = aws_ssm_parameter.default_timeout_ms.value
  sensitive   = true
}

output "app_port_value" {
  description = "Stored value of the application port parameter (as string)."
  value       = aws_ssm_parameter.app_port.value
  sensitive   = true
}

output "spel_cache_max_size_value" {
  description = "Stored value of the SpEL cache max-size parameter (as string)."
  value       = aws_ssm_parameter.spel_cache_max_size.value
  sensitive   = true
}

output "spel_cache_expire_minutes_value" {
  description = "Stored value of the SpEL cache TTL parameter (as string)."
  value       = aws_ssm_parameter.spel_cache_expire_minutes.value
  sensitive   = true
}
