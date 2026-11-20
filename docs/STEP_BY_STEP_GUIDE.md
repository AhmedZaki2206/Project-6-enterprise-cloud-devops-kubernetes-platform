# دليل البناء خطوة بخطوة — من Windows لحد Kubernetes

الدليل ده مبني على الملفات الموجودة فعلًا في المشروع. نفّذ أوامر Linux داخل **WSL2 Ubuntu**، وأوامر Docker هتشتغل عن طريق Docker Desktop integration. متنفّذش `terraform apply`؛ جزء AWS هنا blueprint للـvalidation فقط.

## 1. تجهيز Windows 11 وWSL2

**WHY:** WSL2 بيديك Linux shell قريب من بيئة CI، وDocker Desktop بيوفر Docker Engine المستخدم بواسطة Kind.

**COMMAND (PowerShell as Administrator):**

```powershell
wsl --install -d Ubuntu
wsl --update
wsl --status
```

أعد تشغيل الجهاز لو Windows طلب. افتح Docker Desktop ثم Settings → Resources → WSL Integration وفعل Ubuntu.

**EXPECTED RESULT:** `wsl --status` يعرض Default Version: 2. داخل Ubuntu نفّذ `docker version` ولازم يظهر Client وServer.

**COMMON ERRORS:** لو `docker: command not found` فعّل WSL integration وأعد فتح terminal. لو virtualization disabled فعّله من BIOS وWindows Features.

## 2. تثبيت الأدوات داخل Ubuntu

```bash
sudo apt update
sudo apt install -y git make curl unzip python3 python3-venv python3-pip
git --version && python3 --version && make --version
```

ثبّت `kubectl`, Kind, Helm, وTerraform من صفحاتهم الرسمية وبإصدارات تناسب جهازك. بعد التثبيت:

```bash
docker version
kubectl version --client
kind version
helm version --short
terraform version
```

**HOW TO VERIFY:** كل command يرجع version بدون error. `kubectl` مش محتاج cluster في الخطوة دي.

## 3. تنزيل المشروع وإنشاء Python environment

```bash
git clone https://github.com/AhmedZaki2206/Project-6-enterprise-cloud-devops-kubernetes-platform.git
cd Project-6-enterprise-cloud-devops-kubernetes-platform
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
ruff check app tests
pytest
```

`venv` بيعزل dependencies. `requirements-dev.txt` يضم runtime packages وpytest/ruff. الاختبارات تستدعي FastAPI عن طريق `TestClient` من غير network server.

**EXPECTED:** Ruff بدون findings وpytest يعرض 6 passed. الرقم ده expected مش نتيجة تنفيذ؛ راجع `docs/TEST_RESULTS.md` للنتيجة الحقيقية.

## 4. فهم وتشغيل التطبيق

`app/main.py` يعرف `Server` Pydantic model، بيانات fictional، endpoints، وJSON stdout logging. `APP_VERSION`, `APP_ENV`, `LOG_LEVEL` بييجوا من environment.

```bash
APP_ENV=learning APP_VERSION=demo-1 uvicorn app.main:app --host 127.0.0.1 --port 18080
curl http://127.0.0.1:18080/health/ready
curl http://127.0.0.1:18080/api/servers/1
curl -i http://127.0.0.1:18080/api/servers/999
```

**VERIFY:** ready ترجع `{"status":"ready"}`؛ ID 999 يرجع HTTP 404. أوقف server بـ`Ctrl+C`.

## 5. Docker من source code لimage

```bash
docker build --build-arg APP_VERSION=demo-1 -t infrastructure-operations-api:demo-1 .
docker run --rm -d --name infra-api -p 18081:8080 infrastructure-operations-api:demo-1
docker logs infra-api
docker inspect --format '{{.State.Health.Status}} {{.Config.User}}' infra-api
curl http://127.0.0.1:18081/version
docker stop infra-api
```

Builder stage يعمل wheels؛ runtime stage يثبتها في image أصغر. PID الأساسي هو Uvicorn. `-p 8080:8080` بيربط host port بالcontainer port. المستخدم `10001:10001` مش root.

**TROUBLESHOOTING:** لو port مستخدم اختار host port فاضي مثل `-p 18082:8080`. لو Docker daemon unavailable افتح Docker Desktop. استخدم `docker logs` و`docker inspect` قبل إعادة البناء.

## 6. Terraform validation للـAWS blueprint

```bash
cd terraform
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
cd ..
```

`init -backend=false` ينزل AWS provider لكن لا يجهز remote state. `validate` يفحص syntax والreferences؛ لا ينشئ موارد. `plan` اختياري ويتطلب AWS authentication ويعمل API calls. ممنوع تحط keys في الملفات.

**VERIFY:** `Success! The configuration is valid.`. لو provider download فشل راجع الإنترنت/proxy. لو credentials error ظهر في `plan` ده متوقع بدون authorized account.

## 7. Ansible للـUbuntu VM الاختياري

عدّل `ansible/inventory.ini` لعنوان disposable VM، مش جهازك الأساسي.

```bash
cd ansible
ansible-playbook --syntax-check site.yml -i inventory.ini
ansible all -m ping -i inventory.ini
ansible-playbook site.yml -i inventory.ini --check --diff
ansible-playbook site.yml -i inventory.ini
cd ..
```

Role `lab_host` يثبت packages وDocker وkubectl/Kind/Helm، ينشئ user اسمه `devops` ويعمل version/df checks. Handler يعيد Docker فقط لو user group تغيّر. لا يعدل SSH أو firewall.

## 8. إنشاء Kind cluster

```bash
make kind-up
kubectl cluster-info --context kind-enterprise-devops
kubectl get nodes -o wide
```

`kubernetes/kind-config.yaml` ينشئ control-plane وworker، ويربط host `18080` بـNodePort `30080`. Kind nodes نفسهم Docker containers. اخترنا 18080 لتقليل تعارضه مع خدمات محلية شائعة على 8080.

## 9. Helm deployment اليدوي

```bash
helm lint helm/enterprise-platform
helm template enterprise-platform helm/enterprise-platform --namespace enterprise-platform
make deploy
kubectl get all -n enterprise-platform
make health
```

`make deploy` يبني image، يعمل `kind load docker-image`، يطبق namespace restricted، ثم `helm upgrade --install`. Deployment يعمل Podين؛ Service يختارهم بالlabels؛ ConfigMap يمرر configuration؛ ServiceAccount token مقفول.

**EXPECTED:** rollout complete، Podين `Running` و`Ready 1/1`، وcurl health ينجح. لو `ImagePullBackOff` تأكد إن اسم cluster/image مطابق ثم أعد `kind load docker-image ...`.

## 10. Upgrade وrollback وscaling

```bash
TAG=demo-2 make deploy
helm history enterprise-platform -n enterprise-platform
kubectl rollout status deployment/enterprise-platform -n enterprise-platform
REPLICAS=4 make scale
make rollback
```

Helm يسجل revisions. RollingUpdate مضبوط `maxUnavailable: 0` و`maxSurge: 1`. `make rollback` يرجع revision 1 للتدريب؛ في التشغيل الحقيقي اختار revision سليم من `helm history`.

## 11. GitHub Actions وGHCR

عند PR، `.github/workflows/ci.yml` يشغل tests, image scan, Terraform/Helm/Ansible validation فقط. مفيش deployment. بعد merge approved إلى main، job منفصل يبني image ويعمل push بـGit SHA باستخدام `GITHUB_TOKEN`. لو package private غيّر visibility من GitHub Packages settings أو اعمل local image load.

## 12. الـincident labs

```bash
./scripts/lab.sh list
./scripts/lab.sh start 06
./scripts/lab.sh verify 06
kubectl get endpoints web -n incident-06
./scripts/lab.sh reset 06
```

كل lab namespace منفصل. راجع `HANDS_ON_LABS.md` قبل الحل. متستخدمش global delete.

## 13. Safe cleanup

```bash
make clean
docker image rm infrastructure-operations-api:local  # optional
deactivate
```

`make clean` يزيل release/namespace/cluster الخاصين بالمشروع فقط. لا يمس AWS أو clusters ثانية. للتحقق: `kind get clusters` و`kubectl config get-contexts`.
