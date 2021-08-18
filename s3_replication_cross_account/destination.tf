resource "aws_kms_key" "destination" {
  provider = aws.destination

  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.destination_kms_key.json
}

data "aws_iam_policy_document" "destination_kms_key" {
  statement {
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.source.account_id
      ]
    }

    actions = [
      "kms:Encrypt"
    ]

    resources = ["*"]
  }

  statement {
    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.destination.account_id
      ]
    }

    actions = [
      "kms:*"
    ]

    resources = ["*"]
  }
}

resource "aws_s3_bucket" "destination" {
  provider = aws.destination

  bucket = "replication-test-destination-${random_string.random.result}"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.destination.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_policy" "destination" {
  provider = aws.destination

  bucket = aws_s3_bucket.destination.id
  policy = data.aws_iam_policy_document.destination_bucket_policy.json
}

data "aws_iam_policy_document" "destination_bucket_policy" {
  statement {
    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.replication.arn
      ]
    }

    actions = [
      "s3:ReplicateDelete",
      "s3:ReplicateObject"
    ]

    resources = [
      "${aws_s3_bucket.destination.arn}/*"
    ]
  }

  statement {
    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.replication.arn
      ]
    }

    actions = [
      "s3:List*",
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning"
    ]

    resources = [
      aws_s3_bucket.destination.arn
    ]
  }
}

