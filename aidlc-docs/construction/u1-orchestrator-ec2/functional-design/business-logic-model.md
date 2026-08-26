# U1-orchestrator-ec2 — Business Logic Model

## Purpose
Modelar a lógica de provisionamento e operação do orquestrador **EC2 + Docker Compose** (default), agnóstica à sintaxe Terraform.

## Primary Flow — Provision Orchestrator (mode=ec2)

```
1. Assert PlatformContext + existing NetworkCapability (public subnet)
2. Ensure ArtifactBucketCapability (+ upload ComposePackage objects)
3. Provision ExecutionIdentity (EC2 role + instance profile + SSM + base policies)
4. Provision AirflowHost (EC2) with bootstrap (retries on S3 pull + compose up)
5. Enable DagSyncAgent (5-minute timer)
6. Assert OrchestratorReadiness (running + compose healthy + UI :8080 + SSM)
7. Assert SmokeDagList (placeholder DAG synced → visible in Airflow)
8. Publish OrchestratorOutputs (instance id, public IP, UI URL, role ARN, param password path)
```

## Mode Branch

```
IF orchestrator_mode == "ec2":
  run Primary Flow above; DO NOT create MWAA role/environment
ELSE IF orchestrator_mode == "mwaa":
  run legacy U1 MWAA flow (requires account subscription)
```

## Capability Behaviors

### ComposePackage (ArtifactStore extension)
- Objetos sob prefixo `airflow-ec2/` (compose + bootstrap scripts).
- Upload no apply; EC2 **puxa** no boot (não embute o pacote inteiro só no user_data).

### ExecutionIdentity (EC2)
- Trust `ec2.amazonaws.com`; instance profile; `AmazonSSMManagedInstanceCore`.
- Policies de orquestração (artifacts + lake/compute anexos U2/U3) no principal ativo.
- Sem access keys.

### AirflowHost
- EC2 t3.medium AL2023, subnet pública, SG :8080 de `operator_cidr`, **sem** :22.
- Bootstrap: Docker + Compose; pull package; `compose up` com retries limitados; senha UI gerada → SSM Parameter.

### DagSyncAgent
- A cada 5 minutos: `aws s3 sync` `dags/` do ArtifactStore → volume local Compose.
- Operador continua usando `sync-dags.sh` do workstation.

### OperatorAccess
- UI browser no public IP :8080 (IP dinâmico — documentar mudanca pos stop/start).
- Shell via SSM Session Manager.
- Senha UI lida do SSM Parameter (não hardcoded no README como fonte da verdade).

### CostControl
- `stop` / `start` scripts; metadata Airflow (Postgres volume) **sobrevive** stop/start; **destroy** perde metadata.

## Outputs Downstream
| Output | Consumers |
|---|---|
| ec2 role ARN | U3 invoke grants, U4 DAG config |
| public IP / UI URL | Operator, README |
| artifact bucket | sync-dags, DagSyncAgent |
| SSM password param | Operator login |
