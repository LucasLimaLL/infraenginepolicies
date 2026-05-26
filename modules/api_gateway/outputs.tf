output "invoke_url" {
  description = "HTTP API Gateway invoke URL (e.g. https://<id>.execute-api.<region>.amazonaws.com)."
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "api_id" {
  description = "HTTP API Gateway ID."
  value       = aws_apigatewayv2_api.motor.id
}

output "log_group_name" {
  description = "CloudWatch Log Group name for API Gateway access logs."
  value       = aws_cloudwatch_log_group.api_gw_access.name
}

output "api_name" {
  description = "Name of the API."
  value       = aws_apigatewayv2_api.motor.name
}

output "api_protocol_type" {
  description = "Protocol type (HTTP for API Gateway v2)."
  value       = aws_apigatewayv2_api.motor.protocol_type
}

output "api_route_key" {
  description = "Route key configured on the gateway."
  value       = aws_apigatewayv2_route.motor_proxy.route_key
}

output "integration_payload_format_version" {
  description = "Payload format version sent to the backend (must be 1.0 to preserve raw body)."
  value       = aws_apigatewayv2_integration.motor_backend.payload_format_version
}

output "integration_uri" {
  description = "Full integration URI forwarded to by API Gateway."
  value       = aws_apigatewayv2_integration.motor_backend.integration_uri
}

output "log_retention_in_days" {
  description = "Retention of API Gateway access logs in CloudWatch."
  value       = aws_cloudwatch_log_group.api_gw_access.retention_in_days
}
