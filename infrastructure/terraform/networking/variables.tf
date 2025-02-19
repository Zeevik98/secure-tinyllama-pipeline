/*
  variables.tf: Parameterizes the VPC and subnets
*/
variable "aws_region" {
  type        = string
  description = "AWS Region for resource creation"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Project name prefix"
  default     = "secure-eks-cicd"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "private_subnets_cidrs" {
  type        = list(string)
  description = "List of private subnet CIDRs"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets_cidrs" {
  type        = list(string)
  description = "List of public subnet CIDRs"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones to use"
  default     = ["us-east-1a", "us-east-1b"]
}
