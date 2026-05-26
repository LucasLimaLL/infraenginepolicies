output "table_name" {
  description = "Physical name of the DynamoDB table."
  value       = aws_dynamodb_table.politicas.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table."
  value       = aws_dynamodb_table.politicas.arn
}

output "hash_key" {
  description = "Partition key attribute name."
  value       = aws_dynamodb_table.politicas.hash_key
}

output "range_key" {
  description = "Sort key attribute name."
  value       = aws_dynamodb_table.politicas.range_key
}

output "billing_mode" {
  description = "DynamoDB billing mode."
  value       = aws_dynamodb_table.politicas.billing_mode
}

output "pitr_enabled" {
  description = "Whether Point-in-Time Recovery is enabled."
  value       = aws_dynamodb_table.politicas.point_in_time_recovery[0].enabled
}

output "ttl_attribute_name" {
  description = "DynamoDB TTL attribute name."
  value       = aws_dynamodb_table.politicas.ttl[0].attribute_name
}

output "ttl_enabled" {
  description = "Whether DynamoDB TTL is enabled."
  value       = aws_dynamodb_table.politicas.ttl[0].enabled
}
