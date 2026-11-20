# Security Model

## Boundaries and threats

This personal lab protects against accidental secret commits, over-privileged CI, root containers, unbounded workloads and unsafe automatic cloud/deployment changes. It does not claim protection from hostile multi-tenancy or replace production cloud security review.

## Controls implemented

- No credentials, PAT, kubeconfig, Terraform state, `.env`, private key or real Secret in version control.
- GitHub Actions defaults to `contents: read`; only main publish gets `packages: write`.
- Container and Pod run as UID/GID 10001, drop all capabilities, block escalation and use RuntimeDefault seccomp/read-only root filesystem.
- ServiceAccount token is not mounted.
- CPU/memory requests and limits; startup/readiness/liveness probes.
- AWS application SG accepts port 8080 only from the VPC CIDR; no SSH/RDP rules.
- Private AWS route tables have no Internet default route; no paid resource is deployed.
- Trivy scans the built image; Checkov statically scans Terraform.
- The VPC default security group is managed as default-deny. Two Checkov exceptions are documented inline: the reusable example application SG has no EC2/ENI by design, and billable Flow Logs are excluded from the no-cost v1 blueprint.

## Credential handling

Use short-lived AWS federation outside Git and only when an authorized `plan` is needed. GHCR publishing uses GitHub's ephemeral `GITHUB_TOKEN`. For private GHCR local pulls, create an imagePullSecret interactively and delete it with the namespace; never commit the token or rendered Secret.

## Known limitations

Action tags are maintained major/version tags rather than commit-SHA pins and require dependency review. Kind networking and local NodePort are not production perimeter controls. No TLS, NetworkPolicy, admission controller, image signature verification, external secret manager or centralized audit platform is implemented. Base image and pinned packages still need routine updates.

## Reporting

Do not open an issue containing a secret. Revoke/rotate it first, remove it from history using an approved process, then document the non-sensitive impact and fix.
