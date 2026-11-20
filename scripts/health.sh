#!/usr/bin/env bash
set -euo pipefail
NAMESPACE="${NAMESPACE:-enterprise-platform}"
kubectl get deployment,pods,service -n "${NAMESPACE}" -o wide
kubectl rollout status deployment/enterprise-platform -n "${NAMESPACE}" --timeout=120s
curl --fail --silent --show-error "${BASE_URL:-http://127.0.0.1:18080}/health/ready"
echo
