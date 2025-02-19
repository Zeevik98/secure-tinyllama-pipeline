variable "aws_region" {
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  default     = "secure-eks-cicd"
}

variable "private_subnet_id" {
  type        = string
  description = "Private subnet for SageMaker instance"
}

variable "security_group_id" {
  type        = string
  description = "SG for SageMaker instance"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS Key for encryption at rest"
}
