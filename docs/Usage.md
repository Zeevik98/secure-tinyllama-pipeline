# Usage Guide

This guide walks you through deploying the **TinyLlama** model on SageMaker and integrating it with a secure EKS-based pipeline.

## Prerequisites

- AWS account with permissions for VPC, EKS, SageMaker, IAM, S3, etc.
- Terraform ≥ 1.3, kubectl, and optionally helm/istioctl if you plan to manually install Istio.
- GitHub Actions secrets for AWS access, or OIDC-based IAM roles.

## Step-by-Step Deployment

1. **Clone the Repository**

   git clone https://github.com/YOUR_ORG/secure-eks-tinyllama.git
   cd secure-eks-tinyllama


2. **Configure Terraform**
Edit infrastructure/terraform/networking/terraform.tfvars.prod with your VPC CIDR, subnets, region, etc.
Edit infrastructure/terraform/eks/terraform.tfvars.prod to reference the newly created networking outputs, KMS key, etc.
Edit infrastructure/terraform/sagemaker/terraform.tfvars.prod to specify the instance type for the SageMaker Notebook running TinyLlama.

3. **Deploy Networking, EKS, and SageMaker**

cd infrastructure/terraform/networking
terraform init
terraform apply -auto-approve

cd ../eks
terraform init
terraform apply -auto-approve

cd ../sagemaker
terraform init
terraform apply -auto-approve

4.  **Set Up ArgoCD (If not automatically done)**

kubectl create namespace argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd
# or apply your argocd-values.yaml if you have it

5. **ArgoCD Applications:**

Apply infrastructure/ci-cd/argocd/applications.yaml to register the Falco, Istio, and ephemeral scanning namespaces.
ArgoCD now manages those K8s manifests whenever main branch changes.

6. **TinyLlama in SageMaker:**
Go to your AWS console > SageMaker > Notebook Instances.
You should see a notebook named something like secure-eks-cicd-testing (depends on your Terraform config).
Launch it, clone or upload the TinyLlama code into the notebook, and run your model.

7. **CI/CD Flow:**
Whenever you commit/PR changes to the TinyLlama model or pipeline code:
1.GitHub Actions runs lint/tests.
2.If successful, ephemeral scanning pods spin up in EKS (SonarQube, ZAP). ZAP can test the SageMaker endpoint if properly networked.
3.If scans pass, the PR merges → ArgoCD deploys updated resources to EKS.

**Operating the TinyLlama Model**
The model/ directory can store your custom code (e.g., model/tinyllama_inference.py).
The SageMaker Notebook can run it locally or host an inference endpoint. If you create a SageMaker Endpoint, ZAP can target that endpoint for DAST scanning.

