# Hands-on Labs

نفّذ التمارين على Kind cluster مخصص فقط. كل incident معزول في namespace مستقل. قبل ما تقرأ الحل، سجل: symptom، hypothesis، command، evidence، fix.

## Lab 0 — تجهيز البيئة

**Goal:** تثبت إن Docker وKind وHelm متصلين. **Prerequisites:** الأدوات في `STEP_BY_STEP_GUIDE.md`.

```bash
make setup && make test
make kind-up
make deploy
make health
```

**Expected:** nodes Ready، Podين Ready، health JSON. **Hints:** افحص `docker version`, `kind get clusters`, `kubectl config current-context`. **Reset:** `make clean`. **Outcome:** تقدر تفرق بين host/container/cluster.

## Lab 1 — Terraform validation

```bash
cd terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
cd ..
```

**Goal:** validate بدون deployment. **Verify:** valid configuration. **Hint:** `terraform fmt -recursive` يصلح format. **Reset:** احذف `.terraform/` و`.terraform.lock.hcl` فقط لو محتاج clean init؛ لا تحذف state من مشروع حقيقي.

## Lab 2 — Ansible syntax وcheck mode

```bash
ansible-playbook --syntax-check ansible/site.yml -i ansible/inventory.ini
# بعد وضع عنوان disposable VM:
ansible-playbook ansible/site.yml -i ansible/inventory.ini --check --diff
```

**Goal:** تفهم inventory/role/handler/idempotence. **Expected:** syntax pass؛ check mode يعتمد على VM connectivity. **Reset:** لا تشغل على جهازك الأساسي؛ احذف disposable VM من بيئتك فقط.

## Lab 3 — Docker image

```bash
docker build -t infrastructure-operations-api:lab .
docker run --rm -d --name api-lab -p 8081:8080 infrastructure-operations-api:lab
curl http://127.0.0.1:8081/version
docker inspect --format '{{.Config.User}} {{.State.Health.Status}}' api-lab
docker stop api-lab
```

**Goal:** layers, process, ports, non-root. **Verify:** user `10001:10001`; health يصبح healthy. **Reset:** stop يزيل container بسبب `--rm`.

## Lab 4 — حلل GitHub Actions

افتح `.github/workflows/ci.yml`. ارسم dependency بين jobs، وحدد أين permissions تتحول من `contents: read` إلى `packages: write`. شغّل الأوامر محليًا. **Verify:** مفيش `apply`, `kubectl apply`, أو Helm install في CI. **Outcome:** تشرح CI مقابل CD/publish.

## Lab 5 — Helm upgrade وrollback

```bash
helm history enterprise-platform -n enterprise-platform
helm upgrade enterprise-platform helm/enterprise-platform -n enterprise-platform --set replicaCount=3 --set app.version=lab-upgrade --wait
kubectl rollout status deploy/enterprise-platform -n enterprise-platform
helm rollback enterprise-platform 1 -n enterprise-platform --wait
```

**Verify:** replicas/version يتغيروا ثم يرجعوا. **Reset:** `make deploy` يعيد desired local values.

## Incident routine

لكل incident: `./scripts/lab.sh start ID` ثم `verify`. استخدم `get → describe → logs → events`. الحلول موجودة في القسم الأخير؛ حاول 10 دقائق الأول.

### 01 CrashLoopBackOff

**Objective:** تشخيص process بيخرج. **Symptoms:** restarts وBackOff. **Commands:** `kubectl get pod -n incident-01 -w`; `kubectl logs crashloop -n incident-01 --previous`; `kubectl describe pod crashloop -n incident-01`. **Expected root cause:** command ينتهي code 1. **Recovery verification:** بعد fix، restarts تثبت وPod Running. **Reset:** `./scripts/lab.sh reset 01`.

### 02 ImagePullBackOff

**Objective:** قراءة image pull events. **Commands:** `kubectl describe pod bad-image -n incident-02`; `kubectl get events -n incident-02`. **Root cause:** image/tag غير موجود. **Verify fix:** image ID يظهر والPod يبدأ. **Reset:** ID 02.

### 03 Pending Pod

**Objective:** scheduler/resource diagnosis. **Commands:** `kubectl describe pod oversized -n incident-03`; `kubectl get nodes`; `kubectl describe nodes`. **Root cause:** requests أكبر من cluster. **Verify:** Pod Scheduled بعد requests منطقية. **Reset:** ID 03.

### 04 OOMKilled

**Objective:** فهم memory limit. **Commands:** `kubectl get pod memory-pressure -n incident-04`; `kubectl describe pod memory-pressure -n incident-04`; `kubectl logs ... --previous`. **Root cause:** allocation مستمر فوق 24Mi. **Verify:** `lastState.terminated.reason` يتوقف عن OOMKilled بعد fix. **Reset:** ID 04.

### 05 Readiness failure

**Objective:** Pod Running لكن مش Ready. **Commands:** `kubectl describe pod failed-readiness -n incident-05`; `kubectl exec ... -- wget -qO- http://127.0.0.1/`. **Root cause:** `/missing-health` يرجع 404. **Verify:** Ready 1/1 بعد probe path صحيح. **Reset:** ID 05.

### 06 Service selector mismatch

**Objective:** Service بدون endpoints. **Commands:** `kubectl get svc,endpoints,pod --show-labels -n incident-06`; `kubectl describe svc web -n incident-06`. **Root cause:** `wrong-web` لا يطابق `real-web`. **Verify:** endpoints يحتوي Pod IP. **Reset:** ID 06.

### 07 Incorrect ConfigMap

**Objective:** تتبع configuration. **Commands:** `kubectl get cm settings -n incident-07 -o yaml`; `kubectl logs config-consumer -n incident-07 --previous`; `kubectl describe pod ...`. **Root cause:** `APP_MODE=invalid-mode`. **Verify:** Pod يكمل بعد قيمة production وإعادة إنشاء Pod. **Reset:** ID 07.

### 08 Missing Secret

**Objective:** تشخيص CreateContainerConfigError. **Commands:** `kubectl describe pod secret-consumer -n incident-08`; `kubectl get secret -n incident-08`. **Root cause:** `missing-secret` غير موجود. **Verify:** Pod Running بعد Secret محلي مؤقت. **Reset:** ID 08 يحذف secret مع namespace.

### 09 Failed rolling update

**Objective:** rollout/history/recovery. **Commands:** `kubectl rollout status deployment/rollout-lab -n incident-09 --timeout=40s`; `kubectl describe deploy ...`; `kubectl rollout history ...`. **Root cause:** readiness path لا ينجح. **Verify:** available replicas=2 بعد fix/undo. **Reset:** ID 09.

### 10 Ingress 404/502

**Prerequisite:** nginx ingress controller. من غيره النتيجة **NOT RUN** كـrequest test، لكن YAML/events/endpoints تتفحص. **Commands:** `kubectl get ingress,svc,endpoints -n incident-10`; `kubectl describe ingress broken-route -n incident-10`; ingress controller logs. **Root cause:** Service بدون backend Pods فيؤدي 502؛ host/path mismatch قد يؤدي 404. **Verify:** endpoint موجود وhost header صحيح. **Reset:** ID 10.

## Solutions — اقرأ بعد المحاولة

```bash
# 01: اجعل command طويل التشغيل
kubectl patch pod crashloop -n incident-01 --type=json -p='[{"op":"replace","path":"/spec/containers/0/command","value":["sh","-c","sleep 3600"]}]' # immutable: recreate from corrected YAML
# 02: استبدل image بصورة موجودة
kubectl set image pod/bad-image api=busybox:1.36.1 -n incident-02
# 03: قلل requests في YAML ثم recreate
# 04: استبدل البرنامج أو ارفع limit بقيمة محسوبة ثم recreate
# 05: غيّر readiness path إلى /
# 06:
kubectl patch service web -n incident-06 -p '{"spec":{"selector":{"app":"real-web"}}}'
# 07:
kubectl patch configmap settings -n incident-07 --type=merge -p '{"data":{"APP_MODE":"production"}}'
kubectl delete pod config-consumer -n incident-07
# 08 (قيمة تدريب غير حساسة):
kubectl create secret generic missing-secret -n incident-08 --from-literal=token=training-only
# 09: عدل readiness path إلى / أو kubectl rollout undo لو فيه revision سابق
# 10: أنشئ backend Pod label app=absent واستعمل Host: broken.enterprise.local
```

ملحوظة: بعض حقول Pod immutable، فالحل الصحيح هو تعديل manifest ثم حذف/إعادة إنشاء Pod داخل namespace الخاص بالlab. لا تعمل patch عشوائي على المشروع الأساسي.
