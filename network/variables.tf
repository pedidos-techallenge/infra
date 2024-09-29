variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR da VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR das subnets públicas"
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR das subnets privadas"
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}