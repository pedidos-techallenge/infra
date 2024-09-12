provider "aws" {
  region  = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "bucket-tfstates-postech-fiap-6soat"

  versioning {
    enabled = true
  }

  tags = {
    Name = "bucket-tfstates"
  }

  lifecycle {
    prevent_destroy = true
  }

}

resource "aws_iam_policy" "s3_put_policy" {
  name        = "S3PutObjectPolicy"
  description = "Permission to send objects to S3."

  lifecycle {
    prevent_destroy = true
  }

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::bucket-tfstates-postech-fiap-6soat",
          "arn:aws:s3:::bucket-tfstates-postech-fiap-6soat/*"
        ]
      }
    ]
  })
}
