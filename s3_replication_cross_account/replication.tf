resource "aws_iam_role" "replication" {
  name               = "replication-test-${random_string.random.result}"
  assume_role_policy = data.aws_iam_policy_document.replication_role.json
}

resource "aws_iam_role_policy" "replication" {
  name   = "replication"
  role   = aws_iam_role.replication.id
  policy = data.aws_iam_policy_document.replication_policy.json
}

data "aws_iam_policy_document" "replication_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "replication_policy" {
  statement {
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.source.arn
    ]
  }

  statement {
    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging"
    ]

    resources = [
      "${aws_s3_bucket.source.arn}/*"
    ]
  }

  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags"
    ]

    resources = [
      "${aws_s3_bucket.destination.arn}/*"
    ]
  }

  statement {
    actions = [
      "kms:Decrypt"
    ]

    resources = [
      aws_kms_key.source.arn
    ]
  }

  statement {
    actions = [
      "kms:Encrypt"
    ]

    resources = [
      aws_kms_key.destination.arn
    ]
  }
}
