provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "bucket-tfstates-postech-fiap-6soat"
    key            = "cognito.tfstate"
    region         = "us-east-1"
  }
}


# data "aws_lambda_function" "application_entry" {
#   function_name = "application_entry"
# }

# Create Cognito User Pool
resource "aws_cognito_user_pool" "pedidos_cognito" {
  name = "pedidos_user_pool"

  alias_attributes = ["email", "phone_number"]

  password_policy {
    minimum_length    = 8
  }

  username_configuration {
    case_sensitive = false
  }

  auto_verified_attributes = ["email"]

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  # lambda_config {
  #   pre_authentication = data.aws_lambda_function.application_entry.arn
  # }
}

resource "aws_cognito_user_pool_domain" "cognito_domain" {
  domain       = "pos-tech-challenge-soat"
  user_pool_id = aws_cognito_user_pool.pedidos_cognito.id
}

# Create User Pool Client
resource "aws_cognito_user_pool_client" "pedidos_user_pool_client" {
  name         = "pedidos_user_pool_client"
  user_pool_id = aws_cognito_user_pool.pedidos_cognito.id
  generate_secret = false

  callback_urls                   = ["https://example.com"]
  supported_identity_providers    = ["COGNITO"]
}

# Identity Pool
resource "aws_cognito_identity_pool" "pedidos_identity_pool" {
  identity_pool_name               = "pedidos_identity_pool"
  allow_unauthenticated_identities = true

  cognito_identity_providers {
    client_id      = aws_cognito_user_pool_client.pedidos_user_pool_client.id
    provider_name  = aws_cognito_user_pool.pedidos_cognito.endpoint
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "pedidos_identity_pool_roles" {
  identity_pool_id = aws_cognito_identity_pool.pedidos_identity_pool.id

  roles = {
    authenticated = "arn:aws:iam::195169078299:role/LabRole"
  }
}