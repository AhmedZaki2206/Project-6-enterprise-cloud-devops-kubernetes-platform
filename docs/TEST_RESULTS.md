# Validation Results

Executed on Windows 11 with Docker Desktop on **2026-11-20**. A check marked NOT RUN must not be presented as passed. No AWS resource was created.

| Check | Status | Evidence / reason |
|---|---|---|
| Python `ruff check app tests` | PASSED | Ruff 0.8.6: `All checks passed!` |
| Python `pytest` | PASSED | pytest 8.3.4: 6 passed; one Starlette deprecation warning for TestClient/httpx |
| Docker build | PASSED | Docker 29.1.5; rebuilt with current `python:3.12-slim-bookworm` and FastAPI 0.165.0 |
| Container smoke test | PASSED | UID/GID `10001:10001`; `/version` returned build value |
| Trivy image scan | PASSED after remediation | Trivy 0.58.1: first build FAILED (52 OS + 3 Python HIGH/CRITICAL findings); updated base/dependencies; final result `Total: 0 (HIGH: 0, CRITICAL: 0)` |
| Terraform fmt | PASSED after remediation | Terraform 1.10.3: first check found one unformatted module; official formatter applied; recheck exit 0 |
| Terraform init/validate | PASSED | `init -backend=false` and `Success! The configuration is valid.`; AWS provider 5.100.0 lock file generated |
| Checkov | PASSED with documented exclusions | Checkov 3.2.494: 18 passed, 0 failed when excluding CKV2_AWS_11 (billable Flow Logs omitted) and CKV2_AWS_5 (example SG has no compute/ENI) |
| Helm lint/template | PASSED | Helm 3.16.4: 1 chart linted, 0 failed |
| Kubeconform | PASSED | v0.6.7 strict validation: 4 resources valid, 0 invalid/errors |
| Ansible syntax | PASSED | ansible-core 2.18.1 container: `playbook: site.yml` |
| Ansible lint | NOT RUN | `ansible-lint` not installed; syntax was checked in Linux container |
| Kind deployment and health | PASSED after remediation | Kind 0.26.0 / Kubernetes 1.32.0; initial create FAILED because host 8080 was occupied; mapping changed to 18080; 2 nodes Ready, Deployment 2/2, `/health/ready` and `/version` passed |
| Helm upgrade and rollback | PASSED | Revision 2 scaled to 3/3; rollback to revision 1 restored 2/2 and healthy version |
| Incident labs 01–09 runtime | PASSED | Observed CrashLoop/Error, ImagePullBackOff, Pending, OOMKilled, readiness 0/1, empty Service endpoints, bad ConfigMap failure, CreateContainerConfigError, and failed readiness rollout |
| Incident lab 10 resource state | PASSED | Ingress and Service created with no backend endpoints as designed |
| Incident lab 10 HTTP 404/502 | NOT RUN | nginx ingress controller intentionally not installed; prerequisite documented |
| Mermaid SVG generation | PASSED after remediation | Docker renderer download failed; Mermaid CLI 11.4.3 + local Edge generated 3 SVGs; all parsed as valid XML |
| YAML parse | PASSED | 19 non-template YAML files parsed; raw Helm templates excluded and their rendered output validated by Kubeconform |
| Bash syntax | PASSED | `bash -n` passed for all three project scripts |
| Secret pattern scan | PASSED | No AWS access-key, GitHub PAT, or private-key patterns found in project sources |
| Git whitespace check | PASSED | `git diff --check` exit 0 |
| GitHub Actions | NOT RUN | Requires pushed branch/PR run; local equivalents above passed |

## Important remediation evidence

- The security scan was allowed to fail and drove a real update from `python:3.12.8-slim-bookworm`, FastAPI 0.115.6 and Uvicorn 0.34.0 to a current base, FastAPI 0.165.0 and Uvicorn 0.54.0.
- The occupied port belonged outside this project and was not stopped; Kind host mapping moved from 8080 to 18080.
- All incident namespaces were deleted after validation. The dedicated Kind cluster was deleted during final cleanup.

No `terraform plan`, `terraform apply`, AWS deployment, ingress HTTP test, Ansible VM configuration, or GHCR publication is claimed.
