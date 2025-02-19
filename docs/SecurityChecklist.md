# Security Checklist

Ensure each item is configured for maximum security around the TinyLlama + EKS environment:

1. **Private Subnet for SageMaker**  
   - Confirm SageMaker instance is launched in a private subnet (no public IP).  
   - Check `infrastructure/terraform/sagemaker/terraform.tfvars.prod`.

2. **Ephemeral Scanning**  
   - SonarQube Job (SAST) and ZAP Job (DAST) run in EKS, referencing IRSA to store results in S3.  
   - Check `sonarqube-job.yaml`, `zap-job.yaml` in `security-namespace/`.

3. **Pod Security**  
   - Gatekeeper `excludedNamespaces` for Falco’s privileged pods.  
   - Non-privileged pods forcibly restricted in `non-privileged-namespace`.

4. **Istio Strict mTLS**  
   - `istio-strict-mtls.yaml` enforces TLS 1.3 for all service-to-service traffic.  
   - AuthorizationPolicy is set to allow only intended traffic in the mesh.

5. **Falco**  
   - Runs as a DaemonSet in `privileged-namespace`, monitoring host syscalls.  
   - Minimally configured with a top 10 ruleset. Expand as needed.

6. **TinyLlama**  
   - Model code is stored in `model/` or a SageMaker Git repo.  
   - If the model is large or private, ensure you use encrypted S3 or secure ECR for model artifacts.

7. **Alerts & Logging**  
   - (Optional) Falco can forward alerts to Slack or CloudWatch.  
   - Ensure scanning logs, SageMaker logs, and EKS logs are centralized if needed.

8. **Continuous Improvement**  
   - Evaluate advanced OPA constraints (no root user in containers, resource limits).  
   - Expand ephemeral scanning to test new endpoints or integrated microservices.  
   - Keep EKS version updated and regularly patch the SageMaker Notebook environment.

