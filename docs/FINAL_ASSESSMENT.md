# Junior+ Practical Assessment

Complete without AI help. Maximum 100; pass requires **75**, no critical failure, and at least 50% in every category.

| Task | Evidence | Points |
|---|---|---:|
| Explain the full architecture and honest boundaries | whiteboard + request/CI flows | 12 |
| Run Terraform validation | commands and output interpretation | 7 |
| Run Ansible syntax validation | explain inventory/role/handler | 7 |
| Build and inspect Docker image | tag, user, health, layers | 8 |
| Start dedicated Kind cluster | nodes/context verified | 7 |
| Deploy using Helm | release, Pods, endpoint healthy | 10 |
| Troubleshoot 3 randomly selected incidents | evidence, root cause, safe reset | 18 |
| Perform rolling upgrade | rollout/history/version proof | 8 |
| Roll back to working revision | selected revision + health proof | 8 |
| Explain GitHub Actions and GHCR | permissions, SHA tag, no deploy | 6 |
| Explain AWS/Kind separation | correct network boundary | 4 |
| Five-minute English presentation | accurate, structured, honest | 5 |

## Critical failures

Automatic/unauthorized AWS apply; committing a real secret; claiming Kind runs in AWS; deleting unrelated resources; being unable to recover the base deployment; fabricating test evidence. Any one means fail until remediated.

## Scoring guide

- **90–100:** independent, evidence-led, explains trade-offs.
- **75–89:** Junior+ pass; minor prompting or gaps.
- **60–74:** practice required; can follow steps but not fully diagnose.
- **Below 60:** rebuild fundamentals and repeat labs.

For incident selection, write IDs 01–10 on slips or use `shuf -i 1-10 -n 3`; do not preselect familiar labs.
