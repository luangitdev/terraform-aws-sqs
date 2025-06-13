provider "aws" {
  region  = var.authentication.region
  profile = "sqs-project-user"

  default_tags {
    tags = var.tags
  }

  assume_role {
    role_arn = var.authentication.assume_role_arn
  }
}