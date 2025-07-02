resource "aws_dynamodb_table" "this" {
  name         = var.remote_backend.dynamodb_table.name
  billing_mode = var.remote_backend.dynamodb_table.billing_mode
  hash_key     = var.remote_backend.dynamodb_table.hash_key

  attribute {
    name = var.remote_backend.dynamodb_table.hash_key
    type = "S"
  }
}