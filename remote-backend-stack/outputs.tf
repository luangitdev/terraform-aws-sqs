output "dynamodb_table_name" {
  value = aws_dynamodb_table.this.name
}

output "aws_s3_bucket_name" {
  value = aws_s3_bucket.this.id
}