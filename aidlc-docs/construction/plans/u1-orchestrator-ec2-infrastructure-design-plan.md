# U1-orchestrator-ec2 — Infrastructure Design Plan

**Unidade**: U1-orchestrator-ec2 (delta)  
**Cloud**: AWS `us-east-1` / `dev`  
**Saída**: `infrastructure-design.md`, `deployment-architecture.md` (+ update `shared-infrastructure.md`)

Preencha cada `[Answer]:` e avise (`pronto`).

---

## 1. Checklist (após aprovação)

- [x] `infrastructure-design.md` — mapa lógico → recursos AWS
- [x] `deployment-architecture.md` — topologia / apply / mode switch
- [x] Atualizar `shared-infrastructure.md` (EC2 orchestrator outputs)
- [x] Apresentar para aprovação (2 opções)

---

## 2. Perguntas

### Question 1 — Compute (orquestrador EC2)

A) `aws_instance` t3.medium AL2023 na **subnet pública**; var `airflow_instance_type` default `t3.medium`

B) Mesmo que A + **EBS root 30 GiB gp3** explícito (volume para Docker/metadata)

C) Mesmo que B + volume EBS adicional dedicado `/opt/airflow` (separado do root)

X) Other (please describe after [Answer]: tag below)

[Answer]: B (t3.medium AL2023 + EBS root 30 GiB gp3 explícito)

---

### Question 2 — Wiring `orchestrator_mode` no root

A) `count = var.orchestrator_mode == "mwaa" ? 1 : 0` no `module.mwaa`; `count` inverso no `module.airflow_ec2`; policies lake/compute anexam na role ativa

B) `for_each` com mapa de modos (mais verboso)

X) Other (please describe after [Answer]: tag below)

[Answer]: A (count invertido entre module.mwaa e module.airflow_ec2)

---

### Question 3 — IAM EC2 role (módulo identity)

A) Estender `modules/identity` com recursos condicionais (`count` mode=ec2): role + instance profile + SSM core; **não** criar MWAA role se mode=ec2

B) Novo sub-módulo `modules/airflow_ec2_identity` separado do identity existente

X) Other (please describe after [Answer]: tag below)

[Answer]: B (novo sub-módulo modules/airflow_ec2_identity)

---

### Question 4 — Security Group Airflow EC2

A) Novo SG no módulo `network` (`airflow_ec2_security_group_id` output) — ingress 8080/`operator_cidr`, egress all

B) SG definido **dentro** de `modules/airflow_ec2` (self-contained module)

X) Other (please describe after [Answer]: tag below)

[Answer]: B (SG dentro do modules/airflow_ec2, self-contained)

---

### Question 5 — Compose package no repo / S3

A) Arquivos fonte em `terraform/modules/airflow_ec2/files/`; upload via `aws_s3_object` no módulo para `s3://…/airflow-ec2/`

B) Arquivos em `docker/airflow-ec2/` na raiz do repo (fora de modules)

X) Other (please describe after [Answer]: tag below)

[Answer]: A (arquivos em modules/airflow_ec2/files/; upload via aws_s3_object)

---

### Question 6 — SSM Parameter (senha UI)

A) TF cria param **placeholder** vazio/ignored; bootstrap **sobrescreve** com senha gerada (role EC2 precisa `ssm:PutParameter` no path prefix)

B) TF não cria param; bootstrap cria param completo via AWS CLI (mesma permissão)

X) Other (please describe after [Answer]: tag below)

[Answer]: A (TF cria param placeholder; bootstrap sobrescreve com senha gerada)

---

### Question 7 — Monitoramento infra

A) `aws_cloudwatch_metric_alarm` EC2 StatusCheckFailed no módulo `airflow_ec2`; sem SNS action

B) Alarme no root `main.tf` (fora do módulo)

X) Other (please describe after [Answer]: tag below)

[Answer]: A (alarme no módulo airflow_ec2)

---

### Question 8 — Outputs novos (contrato U3/U4)

A) `airflow_ec2_instance_id`, `airflow_ec2_public_ip`, `airflow_ui_url`, `airflow_ec2_role_arn`, `orchestrator_mode`; manter outputs MWAA quando mode=mwaa

B) Output genérico `orchestrator_role_arn` que aponta para EC2 ou MWAA conforme mode

X) Other (please describe after [Answer]: tag below)

[Answer]: B (output genérico orchestrator_role_arn + os específicos da EC2)

---

### Question 9 — Shared infrastructure doc

A) Atualizar `shared-infrastructure.md`: EC2 Airflow como runtime default; MWAA opcional; `orchestrator_role_arn` contract

B) Criar `shared-infrastructure-ec2-amendment.md` separado

X) Other (please describe after [Answer]: tag below)

[Answer]: A (atualizar o shared-infrastructure.md existente)

---

## 3. Após respostas

1. Análise de ambiguidades  
2. **Aprovar plano de infraestrutura** / Solicitar alterações  
3. Gerar artefatos  
4. Gate: Solicitar Alterações | Continuar para Geração de Código
