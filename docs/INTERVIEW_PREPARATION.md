# Junior / Junior+ DevOps Interview Preparation

الأسئلة دي مرتبطة بالكود الحالي. عددها **40 سؤال بالضبط**.

## 1) What is DevOps?
**Short:** ثقافة وممارسات تقلل المسافة بين development وoperations بالأتمتة والfeedback. **شرح:** الهدف مش tool واحدة؛ الهدف delivery قابل للتكرار وآمن. **English:** “DevOps combines collaboration, automation, feedback, and operational ownership to deliver reliable changes faster.” **Project:** GitHub Actions يفحص الكود، وHelm يدير release والrollback.

## 2) What happens when you run a Linux command?
**Short:** الـshell يعمل parsing ثم يشغل process ويعرض stdout/stderr وexit code. **شرح:** الـexit code صفر نجاح وغير صفر failure، وCI يعتمد عليه. **English:** “The shell resolves the executable, creates a process, and propagates its output and exit status.” **Project:** `set -euo pipefail` في scripts يوقف التنفيذ عند error.

## 3) How do you investigate disk pressure?
**Short:** `df -h`, `du`, logs وdeleted-open files. **شرح:** أبدأ filesystem ثم directory ثم process، من غير حذف عشوائي. **English:** “I narrow the issue from filesystem usage to directories and open files, then apply a bounded cleanup.” **Project:** Ansible يجمع `df -h /` كhealth evidence.

## 4) Process vs container?
**Short:** Container process مع namespaces/cgroups وfilesystem image؛ مش VM كاملة. **شرح:** بيشارك host kernel لكن له isolation وحدود. **English:** “A container is an isolated process using the host kernel, while a VM includes a guest operating system.” **Project:** Uvicorn هو PID الأساسي داخل image.

## 5) TCP port mapping means what?
**Short:** تحويل host address/port لcontainer أو service port. **شرح:** `-p 8080:8080` مش بيغير app port الداخلي. **English:** “Port publishing maps a host socket to a container socket.” **Project:** Kind يربط host 8080 بـNodePort 30080 ثم Service لـPod 8080.

## 6) Security Group vs NACL?
**Short:** SG stateful وعلى ENI؛ NACL stateless وعلى subnet. **شرح:** reply traffic تلقائي في SG لكن لازم rules اتجاهين في NACL. **English:** “Security groups are stateful workload controls; network ACLs are stateless subnet controls.” **Project:** SG يقيد 8080 داخل VPC، والـdefault NACL بدون تعقيد زائد.

## 7) Public vs private subnet?
**Short:** التصنيف بالrouting مش الاسم. **شرح:** public route table عنده default route للـIGW؛ private هنا مفيهوش Internet default route. **English:** “A public subnet has a route to an Internet Gateway; a private subnet does not.” **Project:** `aws_route_table.public` فقط فيه `0.0.0.0/0`.

## 8) Why no NAT Gateway?
**Short:** لتجنب cost ولأن blueprint لا يحتاج outbound private workloads. **شرح:** NAT managed مفيد production لكنه billable. **English:** “I intentionally excluded NAT Gateway to keep the validation-only portfolio blueprint cost-free.” **Project:** private route tables local-only.

## 9) What is Terraform state?
**Short:** mapping بين configuration والresources الفعلية. **شرح:** حساس وقد يحتوي metadata؛ لا يدخل Git. **English:** “State records resource identity and attributes so Terraform can calculate changes.” **Project:** `.gitignore` يستبعد `*.tfstate`; demo يستخدم local state لو تم تشغيله يدويًا.

## 10) init, validate, plan, apply?
**Short:** init يجهز providers، validate يفحص config، plan يحسب change، apply ينفذ. **شرح:** validate لا يثبت permissions أو deployability. **English:** “Validation is static; plan may authenticate and query APIs; apply changes infrastructure.” **Project:** CI يقف عند validate/Checkov ولا يعمل apply.

## 11) Why Terraform modules?
**Short:** reuse وحد واضح للinputs/outputs. **شرح:** root يحدد environment values وnetwork module ينفذ VPC. **English:** “Modules encapsulate repeatable infrastructure behind typed variables and outputs.” **Project:** `terraform/modules/network`.

## 12) How do variable validations help?
**Short:** تفشل بدري لو input غير صحيح. **شرح:** أسهل من اكتشاف CIDR/name error بعد provider call. **English:** “Variable validation shifts input errors left.” **Project:** CIDR validity وproject naming rule في `variables.tf`.

## 13) What is Ansible idempotence?
**Short:** إعادة playbook توصل لنفس desired state بدون تغييرات غير لازمة. **شرح:** استخدم modules و`creates` بدل shell العشوائي. **English:** “An idempotent playbook reports no changes when the target already matches the desired state.” **Project:** apt/user/file/get_url/unarchive modules.

## 14) Inventory, playbook, role, handler?
**Short:** inventory targets، playbook orchestration، role تنظيم، handler action عند change. **شرح:** handler لا يعمل كل مرة. **English:** “The inventory selects hosts, a play invokes roles, and handlers react to notified changes.” **Project:** operator group change ينبه Docker restart.

## 15) Why Ansible not directly on Windows Docker Desktop?
**Short:** playbook مصمم Ubuntu عبر SSH. **شرح:** Docker Desktop VM managed environment مش target Linux عام. **English:** “I scope the role to a disposable Ubuntu VM and do not treat Docker Desktop as a normal SSH-managed host.” **Project:** assert Ubuntu ولا يغير Windows firewall/SSH.

## 16) What is a Docker image layer?
**Short:** immutable filesystem delta قابلة للcache. **شرح:** ترتيب COPY/install يؤثر cache والحجم. **English:** “Layers make image builds cacheable and content-addressed.” **Project:** dependencies قبل source لتحسين cache.

## 17) Why multi-stage build?
**Short:** أدوات build تفضل خارج runtime. **شرح:** builder يصنع wheels وruntime يأخذ النتيجة فقط. **English:** “Multi-stage builds separate build tooling from the runtime image.” **Project:** `/wheels` تنتقل من builder للصورة النهائية.

## 18) Why run containers as non-root?
**Short:** يقلل أثر exploit. **شرح:** مش حماية كاملة لكنه defense in depth. **English:** “Running as UID 10001 reduces privileges if the application is compromised.” **Project:** Dockerfile وPod securityContext متطابقين.

## 19) CMD vs ENTRYPOINT?
**Short:** ENTRYPOINT executable ثابت؛ CMD default command/arguments. **شرح:** الاتنين ممكن override بطرق مختلفة. **English:** “ENTRYPOINT defines the executable; CMD commonly supplies defaults.” **Project:** CMD يشغل Uvicorn مباشرة بدون shell.

## 20) What does a Docker healthcheck prove?
**Short:** endpoint داخل container بيرد؛ لا يثبت system كله. **شرح:** Docker health منفصل عن Kubernetes probes. **English:** “It proves the container can answer a local liveness request at that moment.” **Project:** Python urllib يفحص `/health/live`.

## 21) Git branch vs commit?
**Short:** commit snapshot immutable؛ branch pointer متحرك. **شرح:** feature branch يعزل change قبل review. **English:** “A branch points to a sequence of commits; a commit is an immutable snapshot.” **Project:** العمل على `feature/enterprise-cloud-kubernetes-capstone`.

## 22) Why Pull Requests?
**Short:** review، CI evidence، discussion وcontrolled merge. **شرح:** no-conflict مش معناه quality pass. **English:** “A pull request creates a review and validation boundary before main changes.” **Project:** المطلوب عدم merge بدون موافقة.

## 23) CI vs CD?
**Short:** CI validates integration؛ CD يجهز/ينشر artifact أو deploy. **شرح:** هنا publish آلي بعد main لكن Kubernetes deploy يدوي. **English:** “CI tests every change; this project publishes on main but intentionally keeps deployment manual.” **Project:** `publish` job يدفع GHCR فقط.

## 24) Why immutable SHA tags?
**Short:** tag يحدد build بالضبط. **شرح:** `latest` mutable ويصعب rollback/audit. **English:** “A Git SHA tag makes the artifact traceable to one source revision.” **Project:** `${{ github.sha }}` في workflow.

## 25) How is GITHUB_TOKEN secured?
**Short:** token قصير العمر وpermissions محدودة. **شرح:** PR jobs `contents: read`؛ publish فقط `packages: write`. **English:** “I grant package write permission only to the main-branch publish job.” **Project:** permissions job-scoped.

## 26) Pod vs Deployment?
**Short:** Pod أصغر runtime unit؛ Deployment يدير replicas وupdates. **شرح:** ما نديرش standalone Pods للتطبيق. **English:** “The Deployment continuously reconciles the desired Pod replicas and rollout strategy.” **Project:** 2 replicas وRollingUpdate.

## 27) Service purpose?
**Short:** stable virtual endpoint وload balancing للPods. **شرح:** selector لازم يطابق labels. **English:** “A Service decouples clients from ephemeral Pod IPs.” **Project:** incident 06 يوضح selector mismatch.

## 28) ConfigMap vs Secret?
**Short:** ConfigMap non-sensitive؛ Secret encoding مش encryption تلقائيًا. **شرح:** الاثنين ممكن env/volume، لكن real secrets محتاجة secure management. **English:** “I use ConfigMap for ordinary settings and never commit real Secret values.” **Project:** APP_ENV/LOG_LEVEL/APP_VERSION فقط.

## 29) Liveness vs readiness vs startup?
**Short:** liveness يعيد container؛ readiness يوقف traffic؛ startup يحمي البداية البطيئة. **شرح:** probe غلط يعمل outage. **English:** “Startup gates the other probes, readiness controls endpoints, and liveness detects a stuck process.” **Project:** paths منفصلة في values.

## 30) Requests vs limits?
**Short:** requests للscheduling؛ limits سقف runtime. **شرح:** CPU throttling وmemory OOM ممكنين. **English:** “Requests reserve scheduling capacity; limits constrain consumption.” **Project:** incident 03 و04 يبينوا الاثنين.

## 31) CrashLoopBackOff diagnosis?
**Short:** logs current/previous، describe، exit code. **شرح:** BackOff symptom مش root cause. **English:** “I inspect previous container logs and termination state before changing the manifest.” **Project:** incident 01 command exits 1.

## 32) ImagePullBackOff diagnosis?
**Short:** image name/tag، registry access، imagePullSecrets وevents. **شرح:** التطبيق لم يبدأ أصلًا. **English:** “I read pull events, verify the exact image reference, and check registry authentication.” **Project:** incident 02 intentionally nonexistent image.

## 33) Pending Pod diagnosis?
**Short:** scheduler events، requests، taints، selectors وPVC. **شرح:** logs غير متاحة قبل scheduling. **English:** “For a Pending Pod I start with scheduling events, not application logs.” **Project:** incident 03 يطلب 1000 CPU و1Ti.

## 34) How does rolling update work?
**Short:** ReplicaSets قديم وجديد يتغيروا تدريجيًا. **شرح:** readiness وmaxUnavailable/maxSurge يحددوا availability. **English:** “The Deployment adds one new Pod while keeping old Pods available until readiness passes.” **Project:** maxUnavailable 0, maxSurge 1.

## 35) How do you rollback?
**Short:** حدد revision سليم ثم Helm rollback أو rollout undo. **شرح:** rollback artifact/config معًا مهم. **English:** “I inspect release history, choose a known-good revision, roll back, then verify health and events.” **Project:** `helm history` و`make rollback`.

## 36) What does Helm add?
**Short:** templating، values، release history/lifecycle. **شرح:** مش بديل Kubernetes؛ بيرندر manifests. **English:** “Helm packages Kubernetes resources and tracks revisions for repeatable upgrades and rollbacks.” **Project:** chart parameterizes image/probes/resources/Ingress.

## 37) Why Kind instead of EKS?
**Short:** مجاني، محلي، سريع وreproducible. **شرح:** لا يثبت managed-cloud production experience. **English:** “Kind is appropriate for safe local learning; EKS would add cost and cloud operational scope.” **Project:** AWS وKind منفصلين بوضوح.

## 38) How do you troubleshoot an unavailable service?
**Short:** request → ingress → service/endpoints → pod/probe/log. **شرح:** امشِ طبقة طبقة بالدليل. **English:** “I follow the request path and verify each boundary before changing anything.” **Project:** `scripts/troubleshoot.sh` وincident 06/10.

## 39) What security trade-off exists in this lab?
**Short:** local simplicity مقابل production controls. **شرح:** NodePort وKind مناسبين lab، لكن no TLS/network policy/secret manager. **English:** “The lab is hardened at container level but intentionally omits production identity, TLS, and managed control-plane controls.” **Project:** Ingress disabled وServiceAccount token off.

## 40) What would you improve next?
**Short:** pin actions by commit SHA، SBOM/signing، NetworkPolicy، remote state design، ephemeral integration test. **شرح:** أضيفها تدريجيًا بدون ادعاء إنها موجودة. **English:** “My next steps would be supply-chain provenance, signed images, network policies, and an isolated end-to-end Kind CI test.” **Project:** دي future improvements وليست implemented features.

## 60-second presentation

“This is a personal Junior+ DevOps capstone built around an Infrastructure Operations FastAPI service. I package it as a non-root multi-stage Docker image, validate it in GitHub Actions, and publish immutable SHA tags to GHCR only after merge. Locally, Kind runs two replicas managed by Helm with probes, resource controls, structured logs, rolling updates, and rollback. A separate Terraform module models a cost-conscious AWS VPC blueprint but is never automatically applied. Ansible optionally configures a disposable Ubuntu lab VM. I also built ten isolated Kubernetes incident labs to demonstrate evidence-based troubleshooting. The project is intentionally honest: local Kubernetes is not connected to AWS, deployment is manual, and no production claim is made.”

## 5-minute presentation outline

1. **Problem:** أحتاج portfolio يثبت delivery وoperations مش مجرد YAML.
2. **Source:** FastAPI بسيط، fictional data، validation، health/version، JSON logs وpytest.
3. **Artifact:** multi-stage/non-root image وimmutable version.
4. **Pipeline:** PR validation across app/image/IaC/chart/Ansible؛ main publishes GHCR فقط.
5. **Runtime:** Kind → NodePort/optional Ingress → Service → two Pods؛ ConfigMap/probes/resources/securityContext.
6. **Lifecycle:** Helm lint/template/install/upgrade/history/rollback؛ deployment يدوي.
7. **Cloud blueprint:** VPC/2 AZ/public-private routing/SG بدون paid resources؛ منفصل عن Kind.
8. **Automation:** Ansible للVM اختياري؛ Make targets موحدة.
9. **Operations:** 10 incidents، get/describe/logs/events، isolated reset.
10. **Honesty/next steps:** لم أنشر AWS، لا EKS ولا monitoring stack؛ future supply-chain and network policy.

## Follow-up questions to prepare

- لو readiness فشلت أثناء upgrade، إيه اللي يحصل مع `maxUnavailable: 0`؟
- ليه SG egress 443 لا يعطي private subnet Internet وحده؟
- إزاي تعمل GHCR private pull باستخدام imagePullSecret من غير commit؟
- إيه الفرق بين Helm rollback وapplication data rollback؟
- إزاي تثبت إن log structured وقابل للparse؟

## Common interview mistakes

- تقول إن AWS اتنشر أو Kind داخل VPC؛ ده غير صحيح.
- تعتبر passing YAML validation دليل production readiness.
- تحفظ commands بدون شرح evidence أو blast radius.
- تقول Secret مشفر لمجرد إنه base64.
- تبدأ بالحل قبل جمع `describe/logs/events`.
- تنسب project شخصي لخبرة production أو صاحب عمل.
