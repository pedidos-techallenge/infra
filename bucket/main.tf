provider "aws" {
  region  = "us-east-1"
  aws_access_key_id = ${{ secrets.AWS_ACCESS_KEY_ID }}
  aws_secret_access_key = ${{ secrets.AWS_SECRET_ACCESS_KEY }}
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