variable "aws_region" {
  type        = string
  description = "AWS Region for EKS"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID from the networking module"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnet IDs from the networking module"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS Key ARN for secrets encryption in EKS"
  default     = "arn:aws:kms:us-east-1:123456789012:key/YOUR-KEY-ID"
}

variable "project_name" {
  type        = string
  description = "Project name prefix"
  default     = "secure-eks-cicd"
}
