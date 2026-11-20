# Architecture Decisions

## ADR-001 — Kind rather than EKS

**Decision:** Run the real application locally on Kind. **Why:** free, repeatable and safe on a laptop. **Trade-off:** it does not demonstrate managed control-plane, IAM integration or cloud load balancers.

## ADR-002 — AWS is validation-only

**Decision:** Terraform models networking but CI never plans/applies. **Why:** avoid credentials, billable resources and misleading deployment claims. **Trade-off:** static validation cannot prove AWS permissions or runtime behavior.

## ADR-003 — Helm for lifecycle

**Decision:** One lightweight chart. **Why:** values, releases, upgrades and rollback are interview-relevant. **Trade-off:** templating adds indirection; plain manifests might be simpler for one deployment.

## ADR-004 — GitHub Actions

**Decision:** PR validation and main-only GHCR publish. **Why:** close to source and uses short-lived native token. **Trade-off:** action supply chain must be maintained and public minutes/limits may apply.

## ADR-005 — Manual Kubernetes deployment

**Decision:** CI never accesses local Kind. **Why:** no exposed self-hosted infrastructure and clear human control. **Trade-off:** not continuous deployment.

## ADR-006 — No database or monitoring stack

**Decision:** fictional in-memory data and CLI/log operations. **Why:** focus on delivery, Kubernetes, networking and incident response. **Trade-off:** no persistence, metrics dashboards or alerting demonstration.

## ADR-007 — Default NACL, restricted SG

**Decision:** retain VPC default NACL behavior and document stateless trade-offs. **Why:** avoid fragile ephemeral-port rules in a learning blueprint. **Trade-off:** subnet-level filtering is not demonstrated.
