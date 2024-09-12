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
}

resource "aws_iam_policy" "s3_put_policy" {
  name        = "S3PutObjectPolicy"
  description = "Permission to send objects to S3."

  policy = jsonencode({
    "Version" = "2024-09-11",
    "Statement" = [
      {
        "Action" = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Effect"   = "Allow",
        "Resource" = [
          "arn:aws:s3:::bucket-tfstates-postech-fiap-6soat",
          "arn:aws:s3:::bucket-tfstates-postech-fiap-6soat/*"
        ]
      }
    ]
  })
}
