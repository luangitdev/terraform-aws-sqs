resource "aws_iam_user_policy" "backend_s3_access" {
  name = "terraform-s3-backend"
  user = aws_iam_user.sqs_project_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::projeto-sqs-remote-backend"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "arn:aws:s3:::projeto-sqs-remote-backend/*"
      }
    ]
  })
}