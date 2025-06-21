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

variable "queue" {
  type = object({
    name                      = string
    delay_seconds             = number
    max_message_size          = number
    message_retention_seconds = number
    receive_wait_time_seconds = number
  })

  default = {
    name                      = "projeto-sqs"
    delay_seconds             = 90
    max_message_size          = 2048
    message_retention_seconds = 86400
    receive_wait_time_seconds = 10
  }
}

variable "ecs_cluster" {
  type = object({
    name = string
  })

  default = {
    name = "cluster-projeto-sqs"
  }
}

variable "ecs_task_execution_role_name" {
  type    = string
  default = "projeto-sqs-task-execution-role"
}

variable "ecs_task_role_name" {
  type    = string
  default = "projeto-sqs-task-role"
}