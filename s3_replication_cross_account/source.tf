resource "aws_kms_key" "source" {
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_s3_bucket" "source" {
  bucket = "replication-test-source-${random_string.random.result}"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.source.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  replication_configuration {
    role = aws_iam_role.replication.arn

    rules {
      id     = "replicate"
      status = "Enabled"

      source_selection_criteria {
        sse_kms_encrypted_objects {
          enabled = true
        }
      }

      destination {
        account_id         = data.aws_caller_identity.destination.account_id
        bucket             = aws_s3_bucket.destination.arn
        storage_class      = "STANDARD_IA"
        replica_kms_key_id = aws_kms_key.destination.arn
      }
    }
  }
}
