# U3 Compute Executors — Code Generation Plan

**Unidade**: U3 Compute Executors  
**Tipo**: IaC (Terraform modules) + código de exemplo (Lambda/Glue)  
**Workspace root**: `d:\projetos-ia-aws\ia-dlc-mwaa`  
**Código**: NUNCA em `aidlc-docs/`  
**Docs de código**: `aidlc-docs/construction/u3-compute-executors/code/`

**Histórias**: US-06, US-07, parte US-10  
**Dependências**: U1 (VPC, artifact, MWAA role), U2 (data lake bucket)  
**Consumidores**: U4 (invoke/start/run)

Este plano é a **única fonte da verdade** para a Geração de Código da U3.

---

## Etapas de geração (Part 2)

### Etapa 1 — Sources de aplicação
- [x] `src/lambda_marker/handler.py` — escreve marker em `raw/dt=.../`
- [x] `src/glue/glue_passthrough.py` — raw → Parquet `processed/dt=.../`

### Etapa 2 — Module `lambda_executor`
- [x] `terraform/modules/lambda_executor/main.tf`
- [x] Role + function + log group; archive zip do handler
- [x] Outputs: name, arn, role_arn

### Etapa 3 — Module `glue_job`
- [x] `terraform/modules/glue_job/main.tf`
- [x] Role least privilege; `aws_s3_object` script no artifact bucket
- [x] `aws_glue_job` Glue 4.0 / G.1X / 2 workers (vars)
- [x] Outputs: job_name, role_arn

### Etapa 4 — Module `ecs_executor`
- [x] `terraform/modules/ecs_executor/main.tf`
- [x] Cluster, task definition Fargate, execution+task roles, SG egress
- [x] Network: private subnets, assign_public_ip DISABLED
- [x] Command: AWS CLI put marker no lake
- [x] Outputs: cluster_arn, task_definition_arn, sg_id, role ARNs

### Etapa 5 — Root wiring
- [x] Atualizar `terraform/main.tf` com modules U3 + dependências U1/U2
- [x] Vars de sizing (lambda_memory, glue workers, ecs cpu/mem)
- [x] Estender `terraform/outputs.tf` (contrato U3)
- [x] Policy aditiva MWAA: Invoke / StartJobRun / RunTask / PassRole (sem Action `"*"`)

### Etapa 6 — Operator tooling
- [x] `scripts/smoke-compute.sh` — invoke Lambda + start Glue + run ECS (retry/backoff)
- [x] Atualizar `README.md` seção U3 + exemplos CLI
- [x] Revisar `policies/terraform-apply-policy.json` (Sid U3LambdaEcs)

### Etapa 7 — Docs de código (aidlc-docs)
- [x] `aidlc-docs/construction/u3-compute-executors/code/code-generation-summary.md`
- [x] Confirmar `shared-infrastructure.md`

### Etapa 8 — Validação local
- [x] `terraform fmt`
- [x] `terraform validate` — **Success**

---

## Fora do escopo desta geração
- DAG Airflow / SNS (U4)
- ECS Service always-on / ECR / Lambda in VPC
- DLQ / CloudWatch Alarms
- Remote state

---

## Aprovação

**Status**: plano aprovado; Parte 2 executada — aguardando aprovação do código gerado
