terraform {
  backend "s3" {}
}

provider "aws" {}

data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "techchallenge-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "ApplicationEntry"
}

# API Gateway Resource
resource "aws_api_gateway_resource" "application_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "pedidos"
}

# Filas SQS na AWS
resource "aws_sqs_queue" "payment_order_dlq" {
  name = "payment-order-dlq"

  visibility_timeout_seconds = 30
  message_retention_seconds = 1209600  # 14 dias
  max_message_size         = 262144    # 256 KB
  
  tags = {
    Environment = "development"
    Purpose     = "DLQ for payment orders"
  }
}

resource "aws_sqs_queue" "payment_order_main" {
  name = "payment-order-main"
  
  visibility_timeout_seconds = 30
  message_retention_seconds = 345600    # 4 dias
  delay_seconds             = 0
  max_message_size         = 262144    # 256 KB
  
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.payment_order_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Environment = "development"
    Purpose     = "Main payment orders queue"
  }
}

# Outputs para as filas
output "sqs_main_queue_url" {
  value = aws_sqs_queue.payment_order_main.url
}

output "sqs_dlq_queue_url" {
  value = aws_sqs_queue.payment_order_dlq.url
}