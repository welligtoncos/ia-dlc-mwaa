# U4-orchestration-notify — Infrastructure Design Plan

**Unidade**: U4 Orchestration and Notify  
**Cloud**: AWS `us-east-1` / `dev`  
**Saída**: `infrastructure-design.md`, `deployment-architecture.md` (+ update `shared-infrastructure.md`)

Preencha cada `[Answer]:` e avise (`pronto`).

---

## 1. Checklist (após respostas)

- [x] `infrastructure-design.md` — mapa lógico → recursos AWS
- [x] `deployment-architecture.md` — apply / sync / variables / E2E
- [x] Atualizar `shared-infrastructure.md` (SNS + U4 outputs)
- [x] Apresentar para aprovação (2 opções)

---

## 2. Perguntas

### Question 1 — Ambiente / escopo de implantação

A) Mesmo stack Terraform root (`terraform/`); região `us-east-1`; env `dev`; sem workspace novo

B) Sub-stack Terraform separado só para SNS (não recomendado)

X) Other (please describe after [Answer]: tag below)

[Answer]:A (mesmo stack root; sem workspace novo)

---

### Question 2 — Mensageria (módulo SNS)

A) Novo `terraform/modules/sns`: topic + optional email subscription + topic policy (recebe `publisher_role_arn`)

B) Recursos SNS inline no `main.tf` root (sem módulo)

C) Módulo `sns` só com topic/subscription; topic policy no root

X) Other (please describe after [Answer]: tag below)

[Answer]:A (módulo sns completo: topic + subscription opcional + topic policy)

---

### Question 3 — IAM Publish / Athena (onde anexar)

A) Estender `modules/airflow_ec2_identity` com policy SNS Publish + (se faltarem) Athena/Glue GetTable grants escopados; root passa `sns_topic_arn` e ARNs U2

B) Policies U4 criadas no **root** `main.tf` e attach na role via `aws_iam_role_policy` / attachment (identity module intocado)

C) Novo módulo `modules/orchestrator_u4_iam` só para grants U4

X) Other (please describe after [Answer]: tag below)

[Answer]:B (policies U4 no root, attach na role; identity module intocado)

---

### Question 4 — Athena IAM já existente no root

A) **Reusar** policies Athena já anexadas ao `orchestrator_role` no root; U4 só adiciona SNS Publish (+ `glue:GetTable` se ainda não existir)

B) Reescrever bloco Athena do root do zero nesta U4 (risco de drift)

X) Other (please describe after [Answer]: tag below)

[Answer]:A (reusar Athena existente; U4 só adiciona SNS Publish + glue:GetTable se faltar)

---

### Question 5 — Compute / storage para ProviderRuntime

A) Sem novo compute: alterar **bootstrap** em `modules/airflow_ec2/files/bootstrap.sh` (+ upload S3 object) para `pip install -r requirements.txt` no volume; `requirements.txt` na raiz do repo também syncado para ArtifactStore (path documentado)

B) Novo container sidecar só para pip (overkill)

X) Other (please describe after [Answer]: tag below)

[Answer]:A (bootstrap pip install -r requirements.txt; requirements no pacote S3)

---

### Question 6 — Rede

A) Sem mudança de rede: SNS/Athena/APIs via internet/NAT já existentes; sem VPC endpoints novos nesta U4

B) Adicionar VPC interface endpoint para SNS (custo extra lab)

X) Other (please describe after [Answer]: tag below)

[Answer]:A (sem mudança de rede; sem endpoints novos)

---

### Question 7 — Monitoramento

A) Sem novos alarmes; SNS = notificações do DAG; alarme EC2 U1 permanece sem action SNS

B) Adicionar SNS action ao alarme status-check U1 (override NFR Design Q5/Q7)

X) Other (please describe after [Answer]: tag below)

[Answer]:A (sem novos alarmes; SNS = notificações do DAG; alarme U1 sem action)

---

### Question 8 — Outputs / variables Terraform

A) Novos: `sns_topic_arn`, `sns_topic_name`; var `sns_notification_email` default `""`; manter `orchestrator_role_arn` e outputs U2/U3 existentes para o helper de Variables

B) Também output `airflow_variables_map` (objeto pronto para o script)

X) Other (please describe after [Answer]: tag below)

[Answer]:B (outputs SNS + airflow_variables_map pronto pro script)

---

### Question 9 — Shared infrastructure doc

A) Atualizar `shared-infrastructure.md` com NotifyTopic, outputs SNS, contrato Variables Airflow

B) Só docs em `u4-orchestration-notify/infrastructure-design/` (sem shared update)

X) Other (please describe after [Answer]: tag below)

[Answer]:A (atualizar shared-infrastructure.md)

---

## 3. Defaults sugeridos (lab)

| Q | Sugestão |
|---|---|
| 1 | A |
| 2 | A (módulo sns completo) |
| 3 | A (estender airflow_ec2_identity) |
| 4 | A (reusar Athena; add SNS) |
| 5 | A (bootstrap pip) |
| 6 | A |
| 7 | A |
| 8 | B (outputs SNS + variables map helper) |
| 9 | A |
