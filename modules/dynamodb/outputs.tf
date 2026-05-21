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
