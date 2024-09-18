provider "aws" {
  region  = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "bucket-tfstates-postech-fiap-6soat"
  role   = "arn:aws:iam::195169078299:role/LabRole"

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
