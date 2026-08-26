# Clarification Questions — Orquestrador EC2 + Docker Compose

**Change**: Substituir MWAA gerenciado por EC2 `t3.medium` + Docker Compose (Airflow 2.11.2)  
**Contexto já aceito**: Free Tier bloqueia MWAA; instance role (sem chaves); orquestra U2/U3; custo ~US$ 1–2/dia; C e D descartados por agora  
**Instruções**: Preencha cada `[Answer]:` com a letra (ex.: `A`) ou `X` + descrição. Salve o arquivo e avise no chat.

---

## Question 1
Como você acessa a UI do Airflow (porta 8080)?

A) SSH tunnel (EC2 em subnet privada; UI só via `ssh -L 8080:...`) — mais seguro, sem IP público na UI

B) EC2 em subnet pública com SG liberando 8080 só do meu IP (CIDR informado no apply) — UI no browser direto

C) EC2 pública com SG 8080 aberto a `0.0.0.0/0` — só lab descartável (não recomendado)

X) Other (please describe after [Answer]: tag below)

[Answer]: B (subnet pública, SG liberando 8080 só do seu IP)

---

## Question 2
O que fazer com o módulo Terraform `modules/mwaa` (serviço gerenciado bloqueado)?

A) Remover do `main.tf` / apply (não criar MWAA); manter código do módulo no repo documentado como “futuro D” ou arquivar

B) Variável `orchestrator_mode = "ec2" | "mwaa"` com default `ec2` (count/for_each) — permite voltar a MWAA sem reescrever

C) Deixar `modules/mwaa` no root mas com `count = 0` fixo até upgrade

X) Other (please describe after [Answer]: tag below)

[Answer]: B (variável orchestrator_mode = "ec2" | "mwaa" com default ec2)

---

## Question 3
Como as DAGs chegam na EC2?

A) Script `sync-dags.sh` continua enviando ao bucket de artefatos; na EC2 um cron/`aws s3 sync` periodico baixa para o volume do Compose (mesmo padrão mental do MWAA)

B) `user_data` / script clona o git do lab e monta `dags/` no Compose (sem depender de sync S3 para DAGs)

C) Só sync manual via SSM/SSH (`aws s3 sync` ou `scp`) quando o operador quiser

X) Other (please describe after [Answer]: tag below)

[Answer]: A (sync-dags.sh → bucket de artefatos; aws s3 sync periódico na EC2)

---

## Question 4
Onde colocar a EC2 na VPC do lab?

A) Subnet **pública** existente (IGW) — SSH/UI mais simples; SG restrito

B) Subnet **privada** — só acesso via Session Manager (SSM), sem SSH key obrigatória; UI via port-forward SSM

X) Other (please describe after [Answer]: tag below)

[Answer]: A (subnet pública; SG restrito)

---

## Question 5
Stack Docker do Airflow nesta EC2 (sem RDS externo)?

A) Compose oficial Apache Airflow 2.11.x com **LocalExecutor** + Postgres **no mesmo Compose** (container) — alinhado a 2.11.2, barato

B) Imagem **aws-mwaa-local-runner** (Compose) — mais parecida com MWAA, versão amarrada ao tag do runner

X) Other (please describe after [Answer]: tag below)

[Answer]: A (Compose oficial 2.11.x, LocalExecutor + Postgres no container)

---

## Question 6
Controle de custo da EC2 — o que o lab deve entregar além do Terraform?

A) Scripts `scripts/airflow-ec2-stop.sh` e `scripts/airflow-ec2-start.sh` (+ documentar terminate/destroy)

B) Apenas documentação no README (stop/start/terminate via Console/CLI)

C) Ambos: scripts + README

X) Other (please describe after [Answer]: tag below)

[Answer]: C (scripts start/stop + README)

---

## Question 7
IAM: a role da EC2 deve **reutilizar/adaptar** a execution role atual (hoje `mwaa-execution` + policies U2/U3) ou criar role nova?

A) Renomear/generalizar para `orchestrator-execution` (ou manter nome e mudar trust para `ec2.amazonaws.com`) e reaproveitar policies lake/compute

B) Nova role `airflow-ec2-execution`; policies lake/compute migradas; role MWAA fica órfã/removida

X) Other (please describe after [Answer]: tag below)

[Answer]: B (nova role airflow-ec2-execution)

---

## Question: Security Extensions
As regras da extensão de segurança devem ser aplicadas neste projeto?

A) Sim — aplicar todas as regras SECURITY como restrições bloqueantes (recomendado para aplicações de nível de produção)

B) Não — pular todas as regras SECURITY (adequado para PoCs, protótipos e projetos experimentais)

X) Other (please describe after [Answer]: tag below)

[Answer]: B

---

## Question: Resiliency Extensions
O baseline de resiliência deve ser aplicado neste projeto?

A) Sim — aplicar o baseline de resiliência como melhores práticas direcionais e orientação de design

B) Não — pular o baseline de resiliência (adequado para PoCs / lab)

X) Other (please describe after [Answer]: tag below)

[Answer]: B

---

## Question: Property-Based Testing Extension
As regras de testes baseados em propriedades (PBT) devem ser aplicadas neste projeto?

A) Sim — aplicar todas as regras PBT como restrições bloqueantes

B) Parcial — aplicar regras PBT apenas para funções puras e round-trips de serialização

C) Não — pular todas as regras PBT

X) Other (please describe after [Answer]: tag below)

[Answer]: C
