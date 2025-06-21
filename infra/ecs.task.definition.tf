resource "aws_ecs_task_definition" "this" {
  family                   = "projeto-sqs-consumer"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name  = "consumer"
      image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.authentication.region}.amazonaws.com/sqs-consumer-app:latest"

      environment = [
        {
          name  = "SQS_QUEUE_URL"
          value = aws_sqs_queue.this.url
        },
        {
          name  = "AWS_DEFAULT_REGION"
          value = var.authentication.region
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.authentication.region
          awslogs-stream-prefix = "ecs"
        }
      }

      essential = true
    }
  ])
}

data "aws_caller_identity" "current" {}