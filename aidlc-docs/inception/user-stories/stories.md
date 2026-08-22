# Histórias de Usuário

**Abordagem**: Epic + Jornada E2E  
**Idioma**: Português  
**AC**: Given/When/Then (jornadas) + checklist (infra TF)  
**Personas**: P1 Platform · P2 Data · P3 Security/Governance  
**Referência**: `aidlc-docs/inception/requirements/requirements.md`

Ordem: provisionar → sync DAG → executar → governar → consultar → notificar → endurecer IAM.

---

## Epic E1 — Fundação de plataforma (rede + MWAA + artefatos)

### US-01 — Provisionar rede mínima para MWAA
**Como** Platform Engineer (P1)  
**Quero** uma VPC com 2 subnets privadas, 1 pública, IGW e 1 NAT  
**Para** o MWAA ter saída à internet sem recursos de rede desnecessários  

**Prioridade**: P0 (jornada)  
**INVEST**: Independente no domínio rede; estimável; testável via plan/apply  

**Critérios de aceitação (checklist TF)**
- [ ] VPC com DNS hostnames/support habilitados
- [ ] 2 subnets privadas em AZs distintas + 1 subnet pública
- [ ] 1 IGW + 1 NAT Gateway na subnet pública
- [ ] Route table privada → NAT; pública → IGW
- [ ] Security group do MWAA com regras mínimas (incl. self-reference conforme guia AWS)
- [ ] Tags `Project`, `Environment`, `ManagedBy=terraform` em todos os recursos de rede

**GWT**
- **Given** variáveis default de CIDR/região `us-east-1`  
- **When** executo `terraform apply` do módulo de rede  
- **Then** as subnets privadas roteiam para o NAT e a pública para o IGW  

---

### US-02 — Provisionar ambiente MWAA (mw1.small, UI pública)
**Como** Platform Engineer (P1)  
**Quero** um ambiente MWAA `mw1.small` com Airflow default `2.11.2` e acesso `PUBLIC`  
**Para** orquestrar DAGs e acessar a UI no PoC  

**Prioridade**: P0  
**Personas**: P1  

**Critérios de aceitação (checklist TF)**
- [ ] `aws_mwaa_environment` com `environment_class = "mw1.small"`
- [ ] `airflow_version` via variável (default `2.11.2`)
- [ ] `webserver_access_mode = "PUBLIC"`
- [ ] `lifecycle.ignore_changes` em `requirements_s3_object_version` e `plugins_s3_object_version`
- [ ] Logging CloudWatch habilitado (scheduler/webserver/worker/dag processing)
- [ ] Ambiente associado às 2 subnets privadas e SG da US-01
- [ ] README documenta override de `airflow_version` se a conta não tiver `2.11.2`

**GWT**
- **Given** rede e bucket de artefatos prontos  
- **When** o apply do MWAA conclui  
- **Then** a UI pública abre e autentica com o usuário MWAA criado  

---

### US-03 — Bucket S3 de artefatos Airflow (DAGs/plugins/requirements)
**Como** Platform Engineer (P1)  
**Quero** um bucket versionado com block public access para DAGs, plugins e requirements  
**Para** o MWAA carregar código sem expor objetos publicamente  

**Prioridade**: P0  
**Personas**: P1, P2  

**Critérios de aceitação (checklist TF)**
- [ ] Bucket com versionamento e `block_public_access` total
- [ ] Prefixos/estrutura para `dags/`, `plugins/` e `requirements.txt` (ou convenção MWAA documentada)
- [ ] Terraform **não** faz upload dos DAGs (deploy via sync — US-05)
- [ ] Tags padrão aplicadas

**GWT**
- **Given** o bucket criado pelo Terraform  
- **When** listo o bucket sem sync  
- **Then** a estrutura base existe e não há política de acesso público  

---

### US-04 — Política IAM mínima para quem executa `terraform apply`
**Como** Platform Engineer (P1) e Security (P3)  
**Quero** um arquivo separado e comentado com a policy mínima do principal de apply  
**Para** criar o stack sem `AdministratorAccess`  

**Prioridade**: P0  
**Personas**: P1, P3  

**Critérios de aceitação (checklist)**
- [ ] Arquivo dedicado (ex.: `policies/terraform-apply-policy.json` + comentários/README)
- [ ] Cobre serviços do stack: EC2/VPC, IAM (roles/policies do stack), S3, MWAA, Glue, Lambda, ECS, Lake Formation, Athena, SNS, Logs, (KMS se usado)
- [ ] Sem `Action: "*"` e sem attach de `AdministratorAccess`
- [ ] Comentários explicam por que cada bloco de permissão existe

**GWT**
- **Given** um principal IAM com apenas essa policy  
- **When** rodo `terraform plan/apply` do stack  
- **Then** o apply não falha por AccessDenied nas ações previstas do escopo  

---

## Epic E2 — Publicação e execução da pipeline

### US-05 — Publicar DAG e requirements via `aws s3 sync`
**Como** Data Engineer (P2)  
**Quero** sincronizar `dags/` e `requirements.txt` do repo para o bucket MWAA  
**Para** o ambiente enxergar o DAG de exemplo sem acoplar upload ao Terraform  

**Prioridade**: P0  
**Personas**: P2  

**Critérios de aceitação**
- [ ] Pasta `dags/` no repo com DAG de exemplo
- [ ] `requirements.txt` mínimo (se necessário aos providers)
- [ ] README com comando `aws s3 sync` (e prefixos corretos)
- [ ] Após sync + refresh MWAA, o DAG aparece na UI

**GWT**
- **Given** MWAA healthy e bucket de artefatos  
- **When** executo o sync documentado  
- **Then** o DAG de exemplo fica disponível/unpaused conforme instrução  

---

### US-06 — Executar tarefa Lambda a partir do DAG
**Como** Data Engineer (P2)  
**Quero** que o DAG invoque uma Lambda de exemplo  
**Para** validar o executor serverless leve  

**Prioridade**: P0  
**Personas**: P2, P1  

**Critérios de aceitação (checklist TF + runtime)**
- [ ] Função Lambda Python 3.12 de exemplo provisionada
- [ ] Role da Lambda least privilege
- [ ] Execution role do MWAA com `lambda:InvokeFunction` só na função do stack
- [ ] Task no DAG invoca e trata sucesso/falha

**GWT**
- **Given** DAG publicado e Lambda deployada  
- **When** o DAG dispara a task Lambda  
- **Then** a invocação retorna sucesso e o log aparece no CloudWatch  

---

### US-07 — Executar Glue Job e task ECS Fargate a partir do DAG
**Como** Data Engineer (P2)  
**Quero** iniciar um Glue Job ETL de exemplo e uma task ECS Fargate  
**Para** cobrir executors de ETL e container no mesmo fluxo de aprendizado  

**Prioridade**: P0  
**Personas**: P2, P1  

**Critérios de aceitação (checklist TF + runtime)**
- [ ] Glue Job de exemplo + role least privilege (S3 data lake + Catalog)
- [ ] Cluster ECS + task definition Fargate de exemplo + execution/task roles mínimas
- [ ] MWAA role com ações mínimas Glue (`StartJobRun`, `GetJobRun`, …) e ECS (`RunTask`, `DescribeTasks`, `StopTask` + passar roles)
- [ ] Tasks no DAG cobrem Glue e ECS
- [ ] Crawler e Database Glue existem para alimentar o catalog (pré-governo)

**GWT**
- **Given** data lake e jobs/tasks provisionados  
- **When** o DAG executa as tasks Glue e ECS  
- **Then** ambos concluem com sucesso (ou falha observável com log/SNS)  

---

## Epic E3 — Governança, consulta e notificação

### US-08 — Governar o data lake com Lake Formation e LF-Tags
**Como** Security/Governance (P3)  
**Quero** registrar locations, criar LF-Tags e grants mínimos aos principals do stack  
**Para** praticar governança fine-grained sem abrir o lake inteiro  

**Prioridade**: P0  
**Personas**: P3, P2  

**Critérios de aceitação (checklist TF)**
- [ ] Bucket/prefixos do data lake (`raw/`, `processed/`) com versionamento + BPA
- [ ] Locations registradas no Lake Formation (quando aplicável)
- [ ] LF-Tags (ex.: `Classification`, `Project`) criadas e associadas ao mínimo demonstrável
- [ ] Grants LF aos roles MWAA/Glue/Athena envolvidos — sem admin amplo
- [ ] README com pré-requisito de Data Lake administrator na conta

**GWT**
- **Given** stack aplicado e admin LF configurado  
- **When** um principal sem grant tenta acessar dados tagueados  
- **Then** o acesso é negado; com grant mínimo, o acesso autorizado funciona  

---

### US-09 — Consultar dados via Athena e notificar via SNS
**Como** Data Engineer (P2)  
**Quero** um workgroup Athena com output no lake e um tópico SNS de status do DAG  
**Para** fechar o ciclo consultar + notificar  

**Prioridade**: P1  
**Personas**: P2  

**Critérios de aceitação**
- [ ] Workgroup Athena (ex. `dev`) com results em `athena-results/`
- [ ] Permissões Athena + LF necessárias ao role do MWAA (ou principal de query)
- [ ] Tópico SNS; subscription de e-mail opcional via variável (default vazio)
- [ ] DAG publica sucesso/falha no SNS; inclui task/exemplo de query Athena

**GWT**
- **Given** tabela no Catalog governada  
- **When** o DAG roda query Athena e finaliza  
- **Then** há resultado no prefixo de output e mensagem no tópico SNS  

---

## Epic E4 — Least privilege transversal

### US-10 — Garantir IAM least privilege no execution role do MWAA e roles satélite
**Como** Security/Governance (P3) e Platform (P1)  
**Quero** policies explícitas por serviço (S3, Logs, KMS se houver, Lambda, Glue, ECS, Athena, LF, SNS)  
**Para** cumprir o requisito de não usar wildcards amplos  

**Prioridade**: P0  
**Personas**: P3, P1  

**Critérios de aceitação (checklist)**
- [ ] Nenhuma policy do stack com `Action = "*"`
- [ ] Nenhum attach de `AdministratorAccess`
- [ ] Resources escopados a ARNs do projeto sempre que a API permitir
- [ ] Comentários nos blocos IAM explicam o “porquê”
- [ ] Review cruzado com US-04 (apply role) e roles de Lambda/Glue/ECS/Crawler

**GWT**
- **Given** o código Terraform gerado  
- **When** reviso `iam.tf` / policies anexas  
- **Then** só existem ações necessárias aos FRs aprovados  

---

## Mapa Persona → Histórias

| Persona | Histórias |
|---|---|
| P1 Platform Engineer | US-01, US-02, US-03, US-04, US-06, US-07, US-10 |
| P2 Data Engineer | US-03, US-05, US-06, US-07, US-08, US-09 |
| P3 Security/Governance | US-04, US-08, US-10 |

## Cobertura de requisitos

| Requisito | Histórias |
|---|---|
| FR-01 MWAA | US-02 |
| FR-03 Rede | US-01 |
| FR-02 Bucket artefatos | US-03 |
| FR-04 Data lake S3 | US-08 |
| FR-05 Catalog/Crawler | US-07, US-08 |
| FR-06 Glue Job | US-07 |
| FR-07 Lambda | US-06 |
| FR-08 ECS Fargate | US-07 |
| FR-09 Lake Formation | US-08 |
| FR-10 Athena | US-09 |
| FR-11 SNS | US-09 |
| FR-12 IAM least privilege | US-04, US-10 |
| FR-13 Vars/tags/versions | transversal (Construction) |
| FR-14 DAG exemplo + sync | US-05 |
