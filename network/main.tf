provider "aws" {
  region  = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-private"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-public"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

# Route Table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-route-table"
  }
}

# Route for IGW
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Link the public subnet to route table
resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# Lambda Function
resource "aws_lambda_function" "hello_world" {
  function_name = "hello_world_lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.js"
  runtime       = "nodejs18.x"
  s3_bucket     = "bucket-tfstates-postech-fiap-6soat"
  s3_key        = "lambda.zip"

  # Configure a VPC connection
  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      EXAMPLE_VAR = "HelloWorld"
    }
  }

  tags = {
    Name = "hello-world-lambda"
  }
}

# IAM Role for Lambda Execution
# resource "aws_iam_role" "lambda_exec" {
#   name = "lambda_exec_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action    = "sts:AssumeRole"
#         Effect    = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# # Attach Basic Lambda Permissions to the IAM Role
# resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
#   role       = aws_iam_role.lambda_exec.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

# # API Gateway
# resource "aws_api_gateway_rest_api" "api" {
#   name = "HelloWorldAPI"
# }

# # API Gateway Resource
# resource "aws_api_gateway_resource" "hello_resource" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   parent_id   = aws_api_gateway_rest_api.api.root_resource_id
#   path_part   = "hello"
# }

# # API Gateway Method
# resource "aws_api_gateway_method" "get_method" {
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   resource_id   = aws_api_gateway_resource.hello_resource.id
#   http_method   = "GET"
#   authorization = "NONE"
# }

# # API Gateway Integration with Lambda
# resource "aws_api_gateway_integration" "lambda_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.api.id
#   resource_id             = aws_api_gateway_resource.hello_resource.id
#   http_method             = aws_api_gateway_method.get_method.http_method
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.hello_world.invoke_arn
# }

# # Deploy API Gateway
# resource "aws_api_gateway_deployment" "api_deployment" {
#   depends_on = [aws_api_gateway_integration.lambda_integration]
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   stage_name  = "prod"
# }

# # Lambda Permission for API Gateway Invocation
# resource "aws_lambda_permission" "api_gateway_permission" {
#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.hello_world.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
# }