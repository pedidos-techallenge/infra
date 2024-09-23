provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {}
}

# Create Cognito User Pool
resource "aws_cognito_user_pool" "pedidos_cognito" {
  name = "pedidos_user_pool"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = false
  }

  # Mandatory Attributes Configuration
  schema {
    name     = "cpf"
    attribute_data_type = "String"
    mutable  = false
    required = false
    string_attribute_constraints {
      min_length = 11
      max_length = 11
    }
  }

  schema {
    name     = "email"
    attribute_data_type = "String"
    mutable  = true
    required = false
    string_attribute_constraints {
      min_length = 5
      max_length = 256
    }
  }

# Verification Email
  auto_verified_attributes = ["email"]

# Mensagens de verificação e recuperação
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }
}

# Create User Pool Client
resource "aws_cognito_user_pool_client" "pedidos_user_pool_client" {
  name         = "pedidos_user_pool_client"
  user_pool_id = aws_cognito_user_pool.pedidos_cognito.id
  generate_secret = false

  # OAuth Configuration
  allowed_oauth_flows             = ["code", "implicit"]
  allowed_oauth_scopes            = ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]
  allowed_oauth_flows_user_pool_client = true
  callback_urls                   = ["https://pedidostechchallenge.com/index"]

  # Additional Authentication Configurations
  # explicit_auth_flows = [
  #   "ALLOW_USER_PASSWORD_AUTH",
  #   "ALLOW_REFRESH_TOKEN_AUTH",
  #   "ALLOW_CUSTOM_AUTH",
  #   "ALLOW_USER_SRP_AUTH",
  #   "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  # ]
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