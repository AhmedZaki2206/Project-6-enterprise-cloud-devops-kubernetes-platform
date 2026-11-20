#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LABS_DIR="${ROOT_DIR}/kubernetes/incidents"

usage() { echo "Usage: $0 {list|start|verify|reset} [01-10]"; }
valid_id() { [[ "${1:-}" =~ ^(0[1-9]|10)$ ]]; }
lab_file() { find "${LABS_DIR}" -maxdepth 1 -type f -name "${1}-*.yaml" -print -quit; }

case "${1:-}" in
  list)
    for file in "${LABS_DIR}"/*.yaml; do basename "${file}" .yaml; done
    ;;
  start)
    valid_id "${2:-}" || { usage; exit 2; }
    kubectl apply -f "$(lab_file "$2")"
    ;;
  verify)
    valid_id "${2:-}" || { usage; exit 2; }
    kubectl get all,configmap,secret,ingress -n "incident-$2" 2>/dev/null || true
    kubectl get events -n "incident-$2" --sort-by=.lastTimestamp 2>/dev/null | tail -20 || true
    ;;
  reset)
    valid_id "${2:-}" || { usage; exit 2; }
    kubectl delete namespace "incident-$2" --ignore-not-found --wait=true
    ;;
  *) usage; exit 2 ;;
esac
