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
