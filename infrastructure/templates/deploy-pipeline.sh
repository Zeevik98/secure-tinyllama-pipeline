#!/usr/bin/env bash

# A single script to orchestrate the entire deployment:
# 1) Deploy networking
# 2) Deploy EKS
# 3) Deploy Sagemaker
# 4) Install ArgoCD
# 5) Deploy ArgoCD apps

set -e

echo "=== [1] Deploying Networking ==="
cd infrastructure/terraform/networking
terraform init
terraform apply -auto-approve

echo "=== [2] Deploying EKS ==="
cd ../eks
terraform init
terraform apply -auto-approve

echo "=== [3] Deploying Sagemaker ==="
cd ../sagemaker
terraform init
terraform apply -auto-approve

echo "=== [4] Installing ArgoCD ==="
kubectl create namespace argocd || true
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd --namespace argocd -f ../../templates/argocd-values.yaml

echo "=== [5] Applying ArgoCD Applications ==="
kubectl apply -f ../../ci-cd/argocd/applications.yaml -n argocd
kubectl apply -f ../../ci-cd/argocd/projects.yaml -n argocd

echo "=== Done. Your EKS CI/CD pipeline is ready! ==="
