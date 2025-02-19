# Advanced GitHub Actions Configurations

This directory contains **advanced CI/CD workflows** demonstrating:

1. **Security Scans** with ephemeral Jobs.  
2. **Deploying to SageMaker** with partial rollouts.  
3. **Rollback** logic in case of build or deploy failures.  
4. **Helper Scripts** for more complex tasks (`scripts/` folder).

## Contents

1. **security-scan.yml**  
   - Runs ephemeral scanning pods (SonarQube, ZAP) and checks for vulnerabilities before merges.

2. **deploy-sagemaker.yml**  
   - Demonstrates a multi-step Terraform apply and SageMaker test environment deployment, plus Slack notifications.

3. **rollback.yml**  
   - Illustrates how to revert or roll back an infrastructure change (e.g., if ephemeral scanning or functional tests fail after merge).

4. **scripts/**  
   - Bash scripts that these workflows call for specialized tasks, like shutting down ephemeral scanning pods, or advanced SageMaker manipulation.

## Usage

- In your `.github/workflows/` directory, reference these files (or copy them in).  
- Customize environment variables, Slack webhooks, AWS OIDC credentials, etc.  
- Ensure Terraform backends and ephemeral scanning scripts align with your existing codebase.

For more details, see each file’s inline comments, which explain how everything fits together.  
