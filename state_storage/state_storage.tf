provider "aws" {
  region = "ap-southeast-2"
}

data "aws_region" "current" {}

resource "random_string" "random" {
  length  = 16
  special = false
  upper   = false
}

resource "aws_s3_bucket" "state_storage" {
  bucket = "terraform-state-storage-${random_string.random.result}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_dynamodb_table" "stage_locking" {
  name         = "terraform-state-locking-${random_string.random.result}"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "local_file" "backend_config" {
  filename = "${path.module}/backend.tf"

  content = templatefile("${path.module}/backend.tf.tpl", {
    bucket_name = aws_s3_bucket.state_storage.bucket
    bucket_key  = "example-state-storage"
    table_name  = aws_dynamodb_table.stage_locking.name
    aws_region  = data.aws_region.current.name
  })
}
