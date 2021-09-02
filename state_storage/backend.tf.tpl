terraform {
  backend "s3" {
    bucket         = "${bucket_name}"
    key            = "${bucket_key}"
    dynamodb_table = "${table_name}"
    region         = "${aws_region}"
  }
}

