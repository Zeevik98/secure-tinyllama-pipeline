/*
  main.tf: Creates EKS with the popular terraform-aws-modules/eks. 
*/
terraform {
  backend "s3" {
    bucket = "YOUR-BUCKET-NAME"
    key    = "eks/terraform.tfstate"
    region = "YOUR-REGION"
  }
}

provider "aws" {
  region = var.aws_region
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = "${var.project_name}-cluster"
  cluster_version = "1.25"

  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnets

  manage_aws_auth = true

  node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 2
      instance_types   = ["t3.medium"]
      subnets          = var.private_subnets
    }
  }

  enable_irsa = true
  kms_key_id  = var.kms_key_arn

  tags = {
    Project = var.project_name
  }
}

# EKS Control Plane logging
resource "aws_eks_cluster" "this" {
  name     = module.eks.cluster_id
  role_arn = module.eks.cluster_iam_role_name

  vpc_config {
    subnet_ids = var.private_subnets
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  depends_on = [module.eks]
}

# OIDC Provider for IRSA
data "tls_certificate" "oidc_cert" {
  url = module.eks.cluster_oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = module.eks.cluster_oidc_issuer_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_cert.certificates[0].sha1_fingerprint]
  depends_on      = [module.eks]
}

# Example of installing ISTIO / Falco / OPA in a shell script after cluster creation
resource "null_resource" "install_addons" {
  triggers = {
    cluster_name = module.eks.cluster_id
  }
  provisioner "local-exec" {
    command = <<EOT
echo "Installing ISTIO, Falco, OPA, etc. (helm or kubectl). This can also be done via ArgoCD."
EOT
  }
  depends_on = [module.eks]
}
