/*
  main.tf: Provisions a SageMaker Notebook Instance for testing your TinyLlama model.
  It's placed in a private subnet initially.
*/
terraform {
  backend "s3" {
    bucket = "YOUR-BUCKET-NAME"
    key    = "sagemaker/terraform.tfstate"
    region = "YOUR-REGION"
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_sagemaker_notebook_instance" "testing" {
  name                   = "${var.project_name}-testing"
  instance_type          = "ml.t2.medium"
  role_arn               = aws_iam_role.sagemaker_role.arn
  subnet_id              = var.private_subnet_id
  security_group_ids     = [var.security_group_id]
  kms_key_id             = var.kms_key_arn
  direct_internet_access = "Disabled"  # Because it's in a private subnet

  lifecycle_config_name = aws_sagemaker_notebook_instance_lifecycle_configuration.config.name

  tags = {
    Project = var.project_name
  }
}

resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "config" {
  name    = "${var.project_name}-lifecycle-config"
  on_create = <<EOT
#!/bin/bash
# Example: Install libraries or set up environment
EOT
  on_start = <<EOT
#!/bin/bash
# Example: Additional commands every time the notebook starts
EOT
}

resource "aws_iam_role" "sagemaker_role" {
  name               = "${var.project_name}-sagemaker-role"
  assume_role_policy = data.aws_iam_policy_document.sagemaker_trust.json
}

data "aws_iam_policy_document" "sagemaker_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "sagemaker_attach" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Add more policies as required by your model or data access
