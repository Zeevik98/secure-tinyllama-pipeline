# Architecture Overview

This repository deploys a **secure, automated pipeline** for the **TinyLlama model** using **Amazon SageMaker** and **Amazon EKS**. Key components:

1. **Terraform** for Infrastructure
   - Provisions AWS resources: VPC, EKS cluster, and a private SageMaker Notebook Instance that runs the **TinyLlama** model.

2. **Kubernetes (EKS)**  
   - Hosts ephemeral scanning pods (SonarQube + ZAP).  
   - Runs Falco for runtime security, OPA Gatekeeper for policy enforcement, and Istio for mTLS.  

3. **GitHub Actions (CI)**  
   - Handles linting, unit tests, ephemeral code scans, and Terraform apply steps upon pull requests.

4. **ArgoCD (CD)**  
   - Watches this Git repo for updated **Kubernetes** manifests (e.g., ephemeral scanning Jobs, Falco, Istio).  
   - Synchronizes EKS cluster state with the repo (GitOps).

5. **SageMaker**  
   - Terraform provisions a **Notebook Instance** that loads **TinyLlama**.  
   - The ephemeral **OWASP ZAP** scanner in EKS can test the SageMaker endpoint (when it’s temporarily made accessible).

## High-Level Diagram



## Flow Summary

1. **Developer** modifies **TinyLlama model code** (in `model/` folder) or the pipeline infrastructure code. Pushes changes to a feature branch.  
2. **Pull Request** triggers **GitHub Actions**:  
   - Linting / Unit tests on changed code  
   - Terraform plan/apply if infrastructure changes are detected (including updates to the SageMaker instance).  
   - Ephemeral scanning (SonarQube for code SAST, ZAP for DAST against the SageMaker endpoint if relevant).  
3. If scans/tests pass, the PR merges to `main`.  
4. **ArgoCD** sees new Kubernetes manifests for ephemeral scanning, Falco, Istio, etc., and synchronizes them onto the EKS cluster.  
5. **SageMaker** runs the TinyLlama Notebook in a private subnet. EKS ephemeral scanning pods connect (through VPC networking or an internal endpoint) to test for vulnerabilities.

## Security Highlights

- **SageMaker** in a private subnet (no direct public exposure).  
- **Istio** with strict mTLS (TLS 1.3) for in-cluster service-to-service traffic.  
- **OPA Gatekeeper** forbids privileged pods in `non-privileged-namespace`.  
- **Falco** monitors EKS nodes for suspicious syscall activity.  
- **IRSA** ensures ephemeral scanning pods have minimal S3 read/write for uploading results.

