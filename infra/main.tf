terraform {
  backend "s3" {
    bucket         = "projeto-sqs-remote-backend"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "projeto-sqs-remote-backend-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.authentication.region
  #profile = "sqs-project-user"

  default_tags {
    tags = var.tags
  }

  assume_role {
    role_arn = var.authentication.assume_role_arn
  }
}

#teste de trigger