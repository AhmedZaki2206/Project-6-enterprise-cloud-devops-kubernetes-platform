# Operations Runbook

## Daily health

```bash
kubectl config current-context
kubectl get nodes
kubectl get deploy,pods,svc -n enterprise-platform -o wide
kubectl rollout status deploy/enterprise-platform -n enterprise-platform --timeout=120s
curl -fsS http://127.0.0.1:18080/health/ready
```

Healthy means nodes Ready, desired=available replicas, Pods Ready 1/1, Service endpoints present, HTTP 200. `kubectl top` is optional and works only with metrics-server.

## Deployment

1. `make test` and `helm lint helm/enterprise-platform`.
2. `TAG=<immutable-local-tag> make deploy`.
3. `helm history enterprise-platform -n enterprise-platform`.
4. `make health` and verify `/version`.

State changed: local Docker image, image cache in Kind, namespace objects and Helm revision. AWS is untouched.

## Rollback

```bash
helm history enterprise-platform -n enterprise-platform
helm rollback enterprise-platform <known-good-revision> -n enterprise-platform --wait --timeout 3m
make health
```

Do not blindly select revision 1 outside this lab. Record the failed revision, event evidence, selected revision and post-rollback health.

## Failure diagnosis

```bash
make troubleshoot
kubectl get endpoints enterprise-platform -n enterprise-platform
kubectl describe pod -n enterprise-platform <pod>
kubectl logs -n enterprise-platform <pod> --previous
helm get values enterprise-platform -n enterprise-platform
helm get manifest enterprise-platform -n enterprise-platform
```

Order: scope impact → events → configuration → logs → request path → recent change. Avoid restarts until evidence is captured.

## Scale

`REPLICAS=4 make scale`; verify Deployment and Service endpoints. This is manual scaling, not HPA. Restore with `REPLICAS=2 make scale` or Helm upgrade so live state matches chart values.

## Safe cleanup

`make clean` removes only release `enterprise-platform`, namespace `enterprise-platform`, and Kind cluster `enterprise-devops`. Incident namespaces are normally removed using `./scripts/lab.sh reset ID`; deleting the whole dedicated Kind cluster also removes them. Never use `kubectl delete ns --all`.
