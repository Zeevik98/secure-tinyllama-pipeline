# Advanced Falco Configuration

This directory contains an **extended Falco ruleset** (`rules-extended.yaml`) and a **Falco Sidekick configuration** (`falco-sidekick-config.yaml`) for forwarding alerts to external services (e.g., Slack). These files build upon our existing Falco DaemonSet setup and privileged-namespace approach.

## Overview

1. **Falco Extended Rules** (`rules-extended.yaml`):  
   - Offers advanced detections like cryptominer process detection, suspicious file modifications in `/etc`, kernel module loading, etc.
   - Designed to catch more real-world threat vectors compared to the default Falco set.

2. **Falco Sidekick Config** (`falco-sidekick-config.yaml`):  
   - Deploys Falco Sidekick (often as a separate pod or container in the same namespace as Falco) to forward Falco events to Slack, Splunk, or other endpoints.
   - Includes IRSA annotations if you want to push events to AWS services (e.g., CloudWatch, S3, EventBridge).

## Directory Contents

- **rules-extended.yaml**  
  Verbose Falco rules referencing real-world threats (e.g., cryptomining, privilege escalation attempts).  

- **falco-sidekick-config.yaml**  
  Example config for Falco Sidekick, including Slack output and optional AWS IRSA usage.  

## Prerequisites

- You already have a **Falco DaemonSet** running in a **privileged namespace** (exempted from OPA constraints).  

- If using AWS IRSA for logging to CloudWatch or S3, ensure you’ve created an IAM role with the necessary permissions and annotated your Falco Sidekick ServiceAccount.

## Deployment Steps

**Create or Update Extended Rules**:
   kubectl apply -f rules-extended.yaml -n privileged-namespace


This can be merged with Falco’s existing ConfigMap or loaded as an additional rules file. Adjust falco.yaml accordingly.

**Deploy or Update Falco Sidekick:**
kubectl apply -f falco-sidekick-config.yaml -n privileged-namespace

This spawns a Falco Sidekick pod or updates an existing one with advanced outputs (Slack, etc.).

It designed for Slack as a reffrance but can be modifayed for other services as well.

**Deployment verification:**
-Check Falco logs: kubectl logs ds/falco -n privileged-namespace
-Check Falco Sidekick logs: kubectl logs deploy/falco-sidekick -n privileged-namespace
-Trigger a test event (e.g., kubectl exec -it <some pod> -- bash in non-privileged-namespace) to see if an alert is generated.

**Customization:**
Edit rules-extended.yaml or falco-sidekick-config.yaml to add or remove detection rules, alert routing, or IRSA references as needed.

