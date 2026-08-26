# Application Design Plan — EC2 Airflow Orchestrator

**Projeto**: ia-dlc-mwaa  
**Estágio**: INCEPTION — Design da Aplicação (delta orquestrador)  
**Referências**: `ec2-airflow-orchestrator-requirements.md`, `ec2-airflow-orchestrator-execution-plan.md`  
**Profundidade**: Mínima / delta sobre design existente

Preencha cada `[Answer]:` com a letra. Avise no chat quando concluir (`pronto`).

---

## 1. Checklist de artefatos (gerar após aprovação deste plano)

- [x] Atualizar `components.md` — adicionar OrchestratorEC2; ajustar OrchestratorMWAA (modo opcional); IdentityPlane EC2 role; NetworkFabric SG Airflow EC2
- [x] Atualizar `component-methods.md` — métodos do OrchestratorEC2 / IdentityPlane / DagSyncAgent
- [x] Atualizar `services.md` — OrchestrationService com dual-mode (ec2 | mwaa)
- [x] Atualizar `component-dependency.md` — EC2 role → executors; ArtifactStore → DagSync na EC2
- [x] Atualizar `application-design.md` consolidado (seção amendment)
- [x] Atualizar `unit-of-work.md` — U1 entrega OrchestratorEC2; done-when sem exigir MWAA healthy no default
- [x] Validar consistência com FR-EC2-01..08

---

## 2. Proposta de componentes (delta)

| Componente | Mudança |
|---|---|
| **OrchestratorEC2** (novo) | EC2 t3.medium + Compose Airflow 2.11.2 + EIP + SG; default quando `orchestrator_mode=ec2` |
| **OrchestratorMWAA** | Permanece; só provisionado se `orchestrator_mode=mwaa` |
| **IdentityPlane** | Nova role `airflow-ec2-execution` + instance profile; policies lake/compute no principal ativo |
| **NetworkFabric** | + SG ingress 22/8080 de `operator_cidr` (reuso subnet pública) |
| **ArtifactStore** | Sem mudança de schema; fonte do sync periódico na EC2 |
| **DagSyncAgent** (lógico) | Cron/systemd na EC2: `aws s3 sync` → volume `dags/` (não é módulo TF separado) |
| **PipelineApp / U3 executors** | Consomem role EC2 no modo default |

**TF module proposto**: `modules/airflow_ec2`

---

## 3. Perguntas de design

## Question 1
AMI / SO da EC2?

A) Amazon Linux 2023 (padrão AWS; Docker via dnf/user_data)

B) Ubuntu 22.04 LTS

X) Other (please describe after [Answer]: tag below)

[Answer]: A (Amazon Linux 2023)

---

## Question 2
Acesso SSH à EC2?

A) Key pair existente (nome via variável `ec2_key_name`) + SG 22 do `operator_cidr`

B) Só AWS Systems Manager Session Manager (sem key pair); SG sem 22; UI 8080 do CIDR

C) Key pair **e** SSM (ambos)

X) Other (please describe after [Answer]: tag below)

[Answer]: B (só SSM Session Manager; sem key pair; SG sem porta 22)

---

## Question 3
Onde vivem os arquivos Compose / bootstrap na imagem?

A) Embutidos no `user_data` / templates Terraform (`files/` ou `templates/` no módulo) — sem dependência extra no boot

B) Upload no bucket de artefatos no apply; `user_data` só baixa e sobe o Compose

X) Other (please describe after [Answer]: tag below)

[Answer]: B (Compose/DAGs no bucket de artefatos; user_data só baixa)

---

## Question 4
Nome do módulo Terraform e da role?

A) Módulo `airflow_ec2`; role `…-airflow-ec2-execution` (como nos requisitos)

B) Módulo `orchestrator_ec2`; role `…-orchestrator-execution`

X) Other (please describe after [Answer]: tag below)

[Answer]: A (módulo airflow_ec2; role …-airflow-ec2-execution)

---

## Question 5
EIP (já default nos requisitos) — confirmar?

A) Sim — `aws_eip` associado à EC2 (IP estável para UI/SG mental model)

B) Não — só IP público dinâmico da subnet (mais barato de conceito; IP muda no stop/start)

X) Other (please describe after [Answer]: tag below)

[Answer]: B (sem EIP; IP público dinâmico)

---

## Question 6
Quando `orchestrator_mode=ec2`, o que acontece com a role/policies MWAA no Terraform?

A) **Não criar** role/ambiente MWAA (só EC2 role + policies)

B) Criar role MWAA mesmo assim (órfã), mas sem `aws_mwaa_environment`

X) Other (please describe after [Answer]: tag below)

[Answer]: A (não criar role/ambiente MWAA no modo ec2)

---

## 4. Após suas respostas

1. Análise de ambiguidades (follow-ups se necessário)  
2. Você aprova o plano (`Aprovar plano de design` / `Solicitar alterações`)  
3. Geração dos artefatos listados na seção 1  
4. Gate de aprovação do Design da Aplicação → Construction (Functional Design)
