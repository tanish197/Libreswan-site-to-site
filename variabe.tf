variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "on_prem_cidr" {
  description = "On-premises network CIDR block for VPN static route"
  type        = string
  default     = "10.1.0.0/16"
}

variable "customer_gateway_ip" {
  description = "The IP address of the on-premises VPN gateway"
  type        = string
  default     = "13.232.205.206" # Provide your default IP or leave it empty
}


variable "account_id" {
  type = number
  default = 121263836368
}

variable "environment" {
  type    = string
  default = "Development"
}

variable "aws_access_key" {
  type        = string
  description = "AWS access key"
  sensitive   = true
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
  sensitive   = true
}