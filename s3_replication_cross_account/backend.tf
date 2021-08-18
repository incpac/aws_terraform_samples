provider "aws" {
  region = "ap-southeast-2"
}

provider "aws" {
  alias  = "destination"
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
  }
}

data "aws_caller_identity" "source" {}

data "aws_caller_identity" "destination" {
  provider = aws.destination
}
