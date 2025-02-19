#!/usr/bin/env bash
################################################################################
# cleanup_jobs.sh
#
# A script invoked by GitHub Actions to remove ephemeral scanning jobs, orphaned pods,
# or any leftover resources after scanning is done.
################################################################################

set -euo pipefail

NAMESPACE="${1:-non-privileged-namespace}"

echo "Cleaning up ephemeral scanning jobs in namespace: $NAMESPACE"

kubectl delete job sonarqube-scan -n "$NAMESPACE" --ignore-not-found
kubectl delete job zap-scan -n "$NAMESPACE" --ignore-not-found

# If there are any leftover pods or ephemeral volumes:
PODS=$(kubectl get pods -n "$NAMESPACE" -l app=sonarqube-scan -o name || true)
if [ -n "$PODS" ]; then
  kubectl delete $PODS -n "$NAMESPACE" || true
fi

PODS=$(kubectl get pods -n "$NAMESPACE" -l app=zap-scan -o name || true)
if [ -n "$PODS" ]; then
  kubectl delete $PODS -n "$NAMESPACE" || true
fi

echo "Cleanup completed."
