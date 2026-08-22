# U1 Foundation — Code Generation Plan

**Unidade**: U1 Foundation  
**Tipo**: Greenfield IaC (Terraform modules) — não app OO clássico  
**Workspace root**: `d:\projetos-ia-aws\ia-dlc-mwaa`  
**Código**: NUNCA em `aidlc-docs/`  
**Docs de código**: `aidlc-docs/construction/u1-foundation/code/`

**Histórias**: US-01, US-02, US-03, US-04, US-10 (base)  
**Dependências**: nenhuma unidade anterior  
**Consumidores**: U2–U4 via outputs compartilhados

Este plano é a **única fonte da verdade** para a Geração de Código da U1.

---

## Contexto

| Item | Valor |
|---|---|
| Layout | `terraform/` + `modules/*` + `policies/` + `scripts/` + `README.md` |
| State | Local |
| Region | var default `us-east-1` |
| CIDR | `10.10.0.0/16` (+ subnets documentadas) |
| Extras NFR | SSE-S3, S3 Gateway Endpoint, lifecycle MWAA ignore versions |

---

## Etapas de geração (Part 2)

### Etapa 1 — Estrutura do projeto
- [x] Criar diretórios: `terraform/`, `terraform/modules/{network,artifact_store,identity,mwaa}/`, `policies/`, `scripts/`, `dags/` (placeholder), `aidlc-docs/construction/u1-foundation/code/`

### Etapa 2 — Root Terraform
- [x] `terraform/versions.tf` — TF >= 1.5, AWS ~> 5.0
- [x] `terraform/providers.tf` — provider AWS + default tags
- [x] `terraform/variables.tf` — project, env, region, cidrs, airflow_version, environment_class, tags descriptions
- [x] `terraform/outputs.tf` — outputs shared (vpc, subnets, sg, bucket, mwaa, role)
- [x] `terraform/main.tf` — wiring dos 4 modules na ordem Network → Artifact → Identity → MWAA

### Etapa 3 — Module network (US-01 + S3 endpoint)
- [x] VPC, subnets, IGW, NAT, routes, SG MWAA, S3 Gateway Endpoint
- [x] Comentários o quê/por quê em cada bloco principal

### Etapa 4 — Module artifact_store (US-03)
- [x] Bucket + versioning + BPA + SSE-S3
- [x] Sem upload de DAGs

### Etapa 5 — Module identity (US-04 / US-10 base)
- [x] Execution role MWAA + policies least privilege (S3 artifacts + logs + perms MWAA necessárias)
- [x] Sem `Action="*"` / AdministratorAccess

### Etapa 6 — Module mwaa (US-02)
- [x] `aws_mwaa_environment` mw1.small, PUBLIC, logging, lifecycle ignore requirements/plugins versions

### Etapa 7 — Policy de apply + operador
- [x] `policies/terraform-apply-policy.json` (escopo U1–U4, comentários em README da policy ou arquivo `.md` irmão)
- [x] `policies/README.md` ou comentários no JSON + `docs` checklist IAM
- [x] `scripts/apply.sh` (retry/backoff)
- [x] `scripts/sync-dags.sh` (retry/backoff; sync para bucket)
- [x] `README.md` raiz: init/plan/apply/destroy, avisos PUBLIC UI, NAT SPOF, headroom medium/2 NAT

### Etapa 8 — Placeholder leve + gitignore
- [x] `dags/.gitkeep` (conteúdo DAG em U4)
- [x] `.gitignore` — `.terraform/`, `*.tfstate*`, `.terraform.lock.hcl` opcional keep lock
- [x] Manter `terraform.lock.hcl` se `terraform init` for executável; senão documentar

### Etapa 9 — Documentação de código (aidlc-docs)
- [x] `aidlc-docs/construction/u1-foundation/code/code-generation-summary.md`
- [x] `aidlc-docs/construction/u1-foundation/code/iam-review-checklist.md`

### Etapa 10 — Validação local (best effort)
- [x] Rodar `terraform fmt` nos arquivos gerados
- [x] Rodar `terraform validate` se init possível; senão registrar limitação no summary

---

## Fora do escopo desta geração
- Módulos U2/U3/U4 (lake, compute, SNS, DAG real)
- Backend remoto de state
- Testes unitários de app (N/A); validação = fmt/validate/plan

---

## Aprovação

**Revise este plano.** Para executar a Parte 2 (gerar Terraform real), responda:

- `Aprovar plano de código U1`
- ou `Solicitar alterações` com o que mudar
