resource "aws_sqs_queue" "this" {
  name                      = var.queue.name
  delay_seconds             = var.queue.delay_seconds
  max_message_size          = var.queue.max_message_size
  message_retention_seconds = var.queue.message_retention_seconds
  receive_wait_time_seconds = var.queue.receive_wait_time_seconds
}