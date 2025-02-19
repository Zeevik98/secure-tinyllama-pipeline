# Advanced Istio Configuration

This folder contains **advanced Istio manifests** that extend beyond basic strict mTLS, demonstrating real-world scenarios such as:

1. **Fine-Grained AuthorizationPolicy**  
2. **Egress Traffic Control**  
3. **Custom Telemetry** (metrics and tracing)

These files assume you have already:

- Installed **Istio** (via `istioctl`, Helm, or raw manifests).
- Enabled **STRICT** mTLS (e.g., from `istio-strict-mtls.yaml`).
- Labeled namespaces for sidecar injection (e.g., `istio-injection=enabled`).

Combine them with your existing istio-strict-mtls.yaml for a complete, advanced service mesh setup:
-Strict mTLS ensures in-mesh encryption.
-AuthorizationPolicy controls who can talk to whom.
-Egress restrictions block unauthorized external calls.
-Telemetry provides deeper observability.

## Directory Contents

- **istio-authorization-policy.yaml**  
  Demonstrates advanced rules limiting which services/namespaces can call each other.

- **istio-egress-restrictions.yaml**  
  Restricts traffic leaving the mesh to approved hosts only. This is useful for zero-trust architectures, so workloads can’t call arbitrary external URLs.

- **istio-telemetry.yaml**  
  Custom metrics and tracing configuration, enabling deeper observability (service-level metrics, additional traces).

## How to Use ##

**Apply AuthorizationPolicy** 
   kubectl apply -f istio-authorization-policy.yaml -n <target-namespace>



**Apply Egress Restrictions**
kubectl apply -f istio-egress-restrictions.yaml

**Apply Telemetry**
kubectl apply -f istio-telemetry.yaml -n istio-system


**Verfication**
Check if your services can or cannot call external sites as expected.
Inspect metrics/traces in Prometheus, Grafana, or Jaeger/Zipkin.
Tail logs for the Istio sidecar or pilot to see if the policies are enforced.
