variable "authentication" {
  type = object({
    assume_role_arn = string
    region          = string
  })

  default = {
    assume_role_arn = "arn:aws:iam::135350631478:role/CursoDevopsRole"
    region          = "us-west-2"
  }
}

variable "tags" {
  type = map(string)

  default = {
    Environment = "production"
    Project     = "projeto-sqs"
  }

}

variable "remote_backend" {
  type = object({
    aws_s3_bucket = object({
      name = string
    })

    dynamodb_table = object({
      name         = string
      billing_mode = string
      hash_key     = string
    })
  })

  default = {
    aws_s3_bucket = {
      name = "projeto-sqs-remote-backend"
    }

    dynamodb_table = {
      name         = "projeto-sqs-remote-backend-lock"
      billing_mode = "PAY_PER_REQUEST"
      hash_key     = "LockID"
    }
  }
}