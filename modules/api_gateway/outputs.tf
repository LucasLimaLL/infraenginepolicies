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
