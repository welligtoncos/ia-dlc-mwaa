# Requirements Clarification Questions

Detectei contradições/ambiguidades que precisam ser resolvidas antes de gerar `requirements.md`.

---

## Contradiction 1: Escopo mínimo vs plataforma de dados completa

**Pedido original:** Terraform **MÍNIMO**, menor conjunto de recursos, nada de superfluo; executor = escolher **um** entre Lambda / Glue / ECS.

**Sua resposta Q1:** D — incluir **Lambda + Glue + ECS Fargate + Lake Formation + Athena + S3 data lake + Glue Data Catalog + Glue Crawler + LF-Tags + SNS**.

Essas respostas conflitam em escopo e custo/complexidade.

### Clarification Question 1
Qual escopo deve prevalecer para esta entrega AI-DLC?

A) Manter o escopo **mínimo** do pedido original: MWAA + rede + bucket de DAGs + **um** executor (recomendo Lambda) + IAM least-privilege + política do `terraform apply` — sem Lake Formation/Athena/Crawler/LF-Tags/multi-executor

B) Expandir para a **plataforma de dados completa** descrita na Q1 (Lambda + Glue + ECS + Lake Formation + Athena + Catalog + Crawler + LF-Tags + SNS), aceitando que deixa de ser “stack mínima”

C) Escopo **intermediário**: MWAA mínimo + **S3 data lake** + **Glue Catalog/Crawler** + **um** executor ETL (Glue Job) + SNS; sem ECS, sem Lambda, sem Lake Formation/LF-Tags nesta primeira entrega

D) Other (please describe after [Answer]: tag below)

[Answer]: B (plataforma de dados completa). Você escolheu esse caminho conscientemente ao longo da conversa — pediu "usar o ambiente todo do Lake Formation" e foi somando Athena, Catalog, Crawler, LF-Tags, SNS. É legítimo, só deixa de ser "stack mínima", o que já está claro pra você. Se o objetivo fosse entregar rápido e simples, o C seria o meio-termo mais sensato; mas dado seu intuito de aprender o ambiente de governança inteiro, o B é coerente.
---

## Ambiguity 1: `airflow_version = null` (Q5)

Você pediu `airflow_version = null` para o MWAA usar a versão mais recente automaticamente.

No provider AWS Terraform, `airflow_version` em `aws_mwaa_environment` é **obrigatório** — não há “null = latest”. Omitir ou null falha no plan/apply. O padrão seguro é fixar uma versão suportada via variável (default atualizável).

### Clarification Question 2
Como tratar a versão do Airflow no Terraform?

A) Variável `airflow_version` com default `2.10.3` (ou a mais recente estável documentada no README); documentar como atualizar se a conta não tiver a versão

B) Variável `airflow_version` **sem default** (obrigatória no `terraform apply -var=...`) — você informa a versão disponível na conta no momento do apply

C) Other (please describe after [Answer]: tag below)

[Answer]: A (variável airflow_version com default fixo e documentado), com um ajuste: em vez de 2.10.3, use como default uma versão atual — 2.11.2 se você quer ficar na linha 2.x (mais compatível com material/providers existentes), ou 3.2 se quer já aprender o Airflow moderno (UI nova, event-driven scheduling, Task SDK). Documente no README como trocar caso a região/conta não tenha a versão liberada.

---

## Confirmation (sem conflito, só registrar)

Já aceitos com base nas respostas atuais (não precisam re-responder, a menos que queira mudar):

- Rede: 1x NAT Gateway (Q2 = A)
- State: local (Q3 = A)
- DAGs: sync S3 fora do Terraform (Q4 = A)
- Web UI: PUBLIC (Q6 = B) — PoC
- Extensões: Security = Não, Resiliency = Não, PBT = Não
