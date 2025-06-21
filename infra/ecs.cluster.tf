resource "aws_ecs_cluster" "this" {
  name = var.ecs_cluster.name

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = "aws_cloudwatch_log_group.this.name"
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/projeto-sqs"
  retention_in_days = 7
}
