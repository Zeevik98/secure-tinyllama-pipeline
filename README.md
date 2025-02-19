# Secure TinyLlama CI/CD Pipeline

A comprehensive, production-grade CI/CD pipeline for deploying **TinyLlama** (or similar LLMs) on **AWS SageMaker**, with a **zero-trust** security model leveraging **AWS EKS** for ephemeral scanning and runtime security (Falco, OPA Gatekeeper, Istio).

## Project Overview

This repository provides an end-to-end solution for **securely** deploying LLMs, illustrated by using **TinyLlama** as an example model. Key features include:

- **Automated security scanning** via SonarQube (SAST) and OWASP ZAP (DAST), both running as **ephemeral jobs** in an EKS cluster.
- **Secure model hosting** on SageMaker in a private subnet (no public endpoint by default).
- **Zero Trust** networking via the **Istio** service mesh with strict mTLS (TLS 1.3).
- **Runtime security** with Falco monitoring container behavior for suspicious activity.
- **GitOps-based deployment** using ArgoCD, with additional policy enforcement by OPA Gatekeeper.

## Architecture

Below is a high-level view of the system components:

*(Diagram placeholder; will be added later.)*

### Core Components

1. **AWS EKS**  
   - Hosts ephemeral scanning pods (SonarQube & ZAP) and security tools (Falco, OPA Gatekeeper, Istio).
   - Private subnets (via Terraform) enforce minimal exposure.

2. **AWS SageMaker**  
   - Deploys the TinyLlama model in a secure, private notebook instance or endpoint.
   - Can be tested dynamically by ZAP for DAST if the endpoint is temporarily exposed or internally accessible.

3. **GitHub Actions**  
   - Performs build, lint, and ephemeral scanning triggers.
   - Manages Terraform apply steps for provisioning EKS, networking, and SageMaker.

4. **ArgoCD**  
   - GitOps-based deployment for Kubernetes manifests (scanning jobs, Falco, Istio config).
   - Automatically syncs EKS state to match the repo.

5. **Monitoring & Observability**  
   - Prometheus, Grafana, and optional CloudWatch logging for real-time insights.
   - Falco alerts for suspicious container or node activity.

## Getting Started

### Prerequisites

- **AWS Account** with permissions for VPC, EKS, IAM, and SageMaker.
- **GitHub** repository with Actions enabled for CI/CD.
- **Terraform** (≥ v1.3), **kubectl**, and optionally **helm** (if you prefer a Helm-based Istio/Falco deployment).
- AWS CLI configured for your account (or GitHub OIDC-based IAM roles).

### Deployment Steps ###

1.Clonethis repository:
   git clone https://github.com/YOUR_ORG/secure-tinyllama-pipeline.git
   cd secure-tinyllama-pipeline
2.Configure Terraform:
Update infrastructure/terraform/networking/terraform.tfvars.prod with your VPC and subnet details.
Update infrastructure/terraform/eks/terraform.tfvars.prod with your KMS key ARN, IRSA settings, etc.
Update infrastructure/terraform/sagemaker/terraform.tfvars.prod for the SageMaker instance type and network config.

3.Deploy Infrastructure:
Deploy networking → EKS → SageMaker in that order via Terraform (terraform init && terraform apply in each folder).

4.Install / Configure ArgoCD:
If not already installed, apply argocd/ manifests or run Helm to install ArgoCD in your cluster.
Apply applications.yaml to let ArgoCD manage ephemeral scanning jobs, Falco, Istio, etc.

5.Model Integration:
In SageMaker, launch the notebook instance for TinyLlama and load your model code.
If needed, create a SageMaker endpoint for inference accessible to ZAP for dynamic scanning.

6.GitHub Actions CI:
Push changes or open a pull request.
GitHub Actions runs linting, unit tests, ephemeral scanning (SonarQube & ZAP), and merges changes if everything passes.
ArgoCD automatically syncs any new/updated manifests to EKS.

## Security Features ##
1.Zero Trust
Istio with strict mTLS (TLS 1.3) for service-to-service encryption.
Pod Security: Gatekeeper disallows privileged pods in non-privileged namespaces.
Network Policies to confine traffic within the cluster.

2.Ephemeral Scanning
SonarQube (SAST) and OWASP ZAP (DAST) as Jobs that run only when needed.
IRSA ensures minimal S3 permissions for scanning results.

3.Falco Runtime Security
Deployed as a privileged DaemonSet in a dedicated privileged-namespace.
Monitors syscalls for unexpected container actions and can alert/log suspicious events.

4.KMS Encryption
EKS secrets encrypted with AWS KMS.
SageMaker instance uses KMS for data at rest.

5.SageMaker Isolation
Launched in private subnets to restrict direct inbound traffic.
ZAP scanning can be performed internally if needed for QA or staging checks.


## Monitoring & Observability ##

Prometheus scrapes cluster metrics for real-time monitoring.
Grafana dashboards provide visual insights.
CloudWatch integration captures logs and events.
Falco alerts can be routed to Slack or other channels if configured.


## Contributing ##
Review branch protection rules and security guidelines.
All code changes must pass ephemeral scanning (SAST/DAST) before merges.
Use PRs for any adjustments to Terraform or Kubernetes manifests.

## License ##


### Notes
1. Left the “diagram placeholder” as you requested.  
2. Added multiple references to **SageMaker** hosting **TinyLlama** and how ephemeral scanning can test it.  
3. Emphasized that you have Terraform modules for networking, EKS, **and** Sagemaker.  
4. Mentioned **ArgoCD** for GitOps, **GitHub Actions** for ephemeral scanning & Terraform, and **Falco** + **OPA** for runtime security.
