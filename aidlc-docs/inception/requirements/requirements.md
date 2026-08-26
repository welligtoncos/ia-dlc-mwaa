# Requirements Document

> **Amendment (2026-08-24):** Orquestrador default alterado de MWAA gerenciado para **EC2 + Docker Compose** (Free Tier bloqueia MWAA). Detalhes e FRs da mudança: [`ec2-airflow-orchestrator-requirements.md`](./ec2-airflow-orchestrator-requirements.md). Variável `orchestrator_mode` (`ec2` default | `mwaa`). U2/U3/U4 permanecem; FR-01 abaixo aplica-se quando `orchestrator_mode=mwaa`.

## Intent Analysis Summary

| Field | Value |
|---|---|
| **User request** | Provisionar via Terraform uma pipeline de dados AWS orquestrada por MWAA, com governança Lake Formation de ponta a ponta |
| **Request type** | Novo projeto (greenfield) — IaC Terraform |
| **Scope estimate** | Múltiplos componentes / plataforma de dados |
| **Complexity** | Complexa (MWAA + rede + multi-executor + Lake Formation + Athena + Glue + SNS) |
| **Requirements depth** | Abrangente |
| **Region / Environment** | `us-east-1` / `dev` |

## Decisions Locked (from Q&A)

| Topic | Decision |
|---|---|
| Escopo | **Plataforma completa (B)** — não é mais “stack mínima”; objetivo de aprendizado de governança |
| Executors | Lambda + Glue Job + ECS Fargate (tarefas de exemplo no DAG) |
| Data lake | S3 (raw/processed) + Glue Data Catalog + Glue Crawler |
| Governança | Lake Formation + LF-Tags (fine-grained) |
| Query | Athena |
| Notificações | SNS (sucesso/falha do DAG) |
| Rede | 1× NAT Gateway, 1 subnet pública, 2 subnets privadas |
| Terraform state | Local |
| Deploy de DAGs | Fora do Terraform (`aws s3 sync`) |
| Airflow version | Variável `airflow_version` com **default `2.11.2`** (linha 2.x; mais compatível). Documentar no README como trocar (ex.: `3.x` se disponível na conta/região). **Escolha explícita do modelo entre 2.11.2 e 3.2: `2.11.2`.** |
| Web server | `PUBLIC` (PoC de aprendizado) |
| Security extension | Desabilitada |
| Resiliency extension | Desabilitada |
| PBT extension | Desabilitada |

## Functional Requirements

### FR-01 — Ambiente MWAA
- Provisionar `aws_mwaa_environment` classe `mw1.small`.
- `airflow_version` via variável (default `2.11.2`).
- `webserver_access_mode = PUBLIC`.
- Lifecycle: `ignore_changes = [requirements_s3_object_version, plugins_s3_object_version]`.
- Logging CloudWatch habilitado no mínimo para scheduler/webserver/worker/dag processing (níveis configuráveis via variáveis).

### FR-02 — Bucket de artefatos Airflow
- Bucket S3 dedicado a DAGs / plugins / `requirements.txt`.
- Versionamento habilitado; bloqueio de acesso público.
- Prefixo padrão: `dags/`, `plugins/`, `requirements.txt` (ou pasta `requirements/` conforme convenção MWAA).
- Terraform **não** faz upload dos DAGs; deploy via `aws s3 sync` separado.

### FR-03 — Rede mínima MWAA
- VPC com DNS support/hostnames.
- 2 subnets privadas (2 AZs) para MWAA.
- 1 subnet pública + 1 Internet Gateway + 1 NAT Gateway (AZ única) para saída.
- Security group do MWAA com regras mínimas necessárias (self-referencing para workers/scheduler conforme guia AWS).
- Route tables associadas corretamente (privada → NAT; pública → IGW).

### FR-04 — Data lake S3
- Bucket(s) S3 para data lake (raw e processed — pode ser um bucket com prefixos ou dois buckets; **escolha: 1 bucket com prefixos `raw/` e `processed/`** para reduzir superfície).
- Versionamento + block public access.
- Sem website hosting / ACLs públicas.

### FR-05 — Glue Data Catalog + Crawler
- Database no Glue Catalog.
- Crawler apontando para prefixo `raw/` (ou equivalente) do data lake.
- IAM role do crawler com least privilege (S3 data lake + Glue Catalog).

### FR-06 — Glue Job (executor ETL)
- Job Glue de exemplo (script Spark/PySpark mínimo ou Python shell — **escolha: Glue ETL Spark 4.0 / Python 3** com script placeholder em S3 ou referência gerenciada).
- Role do job com acesso ao data lake e ao Catalog.
- DAG MWAA deve poder iniciar/monitorar o job.

### FR-07 — Lambda (executor leve)
- Função Lambda de exemplo (runtime Python 3.12) com handler trivial (ex.: log + retorno OK).
- Role da Lambda least privilege.
- Permissão para o execution role do MWAA invocar a função.

### FR-08 — ECS Fargate (executor container)
- Cluster ECS mínimo.
- Task definition Fargate de exemplo (imagem pública leve, ex. `public.ecr.aws/amazonlinux/amazonlinux:latest` com comando `echo`/`sleep` — **PoC**).
- Execution role + task role least privilege.
- Subnets privadas + SG permitindo saída necessária.
- Permissões para MWAA executar/descrever tasks.

### FR-09 — Lake Formation + LF-Tags
- Registrar locations do data lake no Lake Formation (quando aplicável).
- Criar LF-Tags (ex.: `Classification=raw|processed`, `Project=<project>`).
- Associar tags a databases/tables/locations conforme mínimo demonstrável.
- Conceder permissões LF ao role do MWAA / Glue / Athena principals envolvidos (sem `AdministratorAccess`).
- **Nota:** Lake Formation em contas novas pode exigir settings de Data Lake administrators — documentar pré-requisito manual.

### FR-10 — Athena
- Workgroup Athena (ex.: `dev`) com resultados em prefixo S3 do data lake (`athena-results/`).
- Permissões para consultar databases/tabelas governados via LF.
- DAG ou documentação de exemplo de query (pode ser task PythonOperator/`AthenaOperator` no DAG de exemplo).

### FR-11 — SNS
- Tópico SNS para status do DAG.
- Subscriptions: variável de e-mail opcional (default vazio; se vazio, só tópico).
- DAG de exemplo publica sucesso/falha (callback ou task final).

### FR-12 — IAM least privilege
- Execution role do MWAA: S3 (artefatos + data lake necessário), CloudWatch Logs, KMS (se usado), e ações mínimas para Lambda invoke, Glue start/get job runs, ECS RunTask/Describe*, Athena StartQuery/Get*, Lake Formation GetDataAccess / permissions necessárias, SNS Publish.
- **Proibido:** `AdministratorAccess`, `Action = "*"` em policies do stack.
- Arquivo separado comentado com política IAM **mínima do principal que executa `terraform apply`**.

### FR-13 — Variáveis, tags e versões
- Sem valores sensíveis hardcoded; `variables.tf` com defaults sensatos e `description` em cada variável.
- Tags padrão em todos os recursos: `Project`, `Environment`, `ManagedBy=terraform`.
- `versions.tf`: `required_version` do Terraform + `required_providers` AWS com constraint de versão.

### FR-14 — DAG de exemplo (fora do TF apply de infra)
- Repo inclui pasta `dags/` com DAG que: invoca Lambda, inicia Glue Job, roda task ECS Fargate, opcionalmente query Athena, publica SNS.
- `requirements.txt` mínimo se providers extras forem necessários.
- Deploy: `aws s3 sync` documentado no README.

## Non-Functional Requirements

### NFR-01 — Segurança
- Block public access em todos os buckets.
- Least privilege IAM.
- Web UI PUBLIC apenas por decisão de PoC (documentar risco).
- Sem secrets no código; usar variáveis / SSM futuro fora do escopo se não necessário.

### NFR-02 — Custo (dev)
- `mw1.small`, 1 NAT, Fargate/Lambda/Glue sob demanda.
- Documentar que MWAA + NAT são os maiores custos fixos.

### NFR-03 — Operabilidade
- State local (PoC); documentar risco de state em disco.
- README com init/plan/apply, sync de DAGs, pré-requisitos (service quotas MWAA, IAM LF admin, região).

### NFR-04 — Manutenibilidade
- Arquivos Terraform separados por domínio:
  - `versions.tf`, `variables.tf`, `outputs.tf` (se útil), `providers.tf` (se necessário)
  - `network.tf`, `iam.tf`, `s3.tf`, `mwaa.tf`
  - `lambda.tf`, `glue.tf`, `ecs.tf`, `lakeformation.tf`, `athena.tf`, `sns.tf`
  - `policies/terraform-apply-policy.json` (ou `.md` + JSON) — política do usuário apply
- Comentários em cada bloco: o que faz e por quê.

## Out of Scope (esta entrega)

- CI/CD de apply Terraform
- Backend remoto de state
- VPN/bastion / PRIVATE_ONLY
- Multi-NAT HA
- Produção hardening completo (WAF, SCPs, etc.)
- Extensões Security / Resiliency / PBT (desabilitadas)

## Prerequisites (manual)

1. Conta AWS com permissões suficientes (ver política de apply gerada).
2. Região `us-east-1` com MWAA disponível.
3. Service quota / disponibilidade de ambiente MWAA.
4. Credenciais AWS CLI configuradas e válidas.
5. Lake Formation: definir Data Lake administrator se a conta ainda usa o modo padrão IAM-only.
6. Confirmar que `airflow_version=2.11.2` está liberada na conta; senão override via `-var`.

## Acceptance Criteria

1. `terraform init && terraform plan` sem erros com variáveis default.
2. `terraform apply` cria MWAA + rede + S3 + Glue/Lambda/ECS + LF/Athena/SNS.
3. Após `aws s3 sync` do DAG, o DAG aparece no MWAA e executa as tarefas de exemplo com sucesso (ou falha observável + SNS).
4. Nenhuma policy do stack usa `Action="*"` ou managed policy AdministratorAccess.
5. Política do executor de Terraform documentada em arquivo separado.

## Key Requirements Summary

- Plataforma de dados **completa** para aprendizado (não stack mínima).
- MWAA `mw1.small`, Airflow default `2.11.2`, UI pública.
- Rede com 1 NAT; state local; DAGs via sync.
- Executors: Lambda + Glue + ECS Fargate.
- Governança: Lake Formation + LF-Tags; catalog/crawler; Athena; SNS.
- IAM least privilege + política mínima do `terraform apply`.
