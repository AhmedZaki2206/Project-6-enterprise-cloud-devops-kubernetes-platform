#!/usr/bin/env bash
set -euo pipefail
NAMESPACE="${NAMESPACE:-enterprise-platform}"
kubectl get all -n "${NAMESPACE}" -o wide
kubectl get events -n "${NAMESPACE}" --sort-by=.lastTimestamp | tail -30
kubectl describe deployment enterprise-platform -n "${NAMESPACE}"
kubectl logs -n "${NAMESPACE}" deployment/enterprise-platform --all-pods=true --tail=100 || true
