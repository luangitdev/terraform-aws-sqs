# Role para execução das tarefas ECS
resource "aws_iam_role" "task_execution" {
  name = var.ecs_task_execution_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Políticas com _attachment são políticas gerenciadas pela AWS
# e são aplicadas diretamente ao papel (role) sem a necessidade de criar uma política personalizada.
resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Role para a aplicação (acesso ao SQS)
resource "aws_iam_role" "task" {
  name = var.ecs_task_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Políticas sem o _attachment são políticas personalizadas que você define
# e aplicam permissões específicas ao papel (role).
resource "aws_iam_role_policy" "sqs_access" {
  name = "sqs-access-policy"
  role = aws_iam_role.task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.this.arn
      }
    ]
  })
}

# resource "aws_iam_user_policy" "ecs_update_service" {
#   name = "ecs-update-service"
#   user = aws_iam_user.sqs_project_user.name

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "ecs:UpdateService"
#         ]
#         Resource = "arn:aws:ecs:us-west-2:135350631478:service/cluster-projeto-sqs/projeto-sqs-consumer-service"
#       }
#     ]
#   })
# }

# resource "aws_iam_user_policy" "backend_s3_access" {
#   name = "terraform-s3-backend"
#   user = aws_iam_user.sqs_project_user.name

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = ["s3:ListBucket"]
#         Resource = "arn:aws:s3:::projeto-sqs-remote-backend"
#       },
#       {
#         Effect   = "Allow"
#         Action   = ["s3:GetObject", "s3:PutObject"]
#         Resource = "arn:aws:s3:::projeto-sqs-remote-backend/*"
#       }
#     ]
#   })
# }