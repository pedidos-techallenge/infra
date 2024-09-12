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

# Check if the policy exists
data "aws_iam_policy" "existing_policy" {
  name = "S3PutObjectPolicy"
}

# Create the policy only if it doesn't already exist
resource "aws_iam_policy" "s3_put_policy" {
  count = length(data.aws_iam_policy.existing_policy.arn) == 0 ? 1 : 0
  name        = "S3PutObjectPolicy"
  description = "Permission to send objects to S3."

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
    lifecycle {
    prevent_destroy = true
  }
}
