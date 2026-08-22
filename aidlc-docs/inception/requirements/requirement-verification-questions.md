# Requirements Clarification Questions

Responda cada pergunta preenchendo a letra após a tag `[Answer]:`.
Se nenhuma opção servir, use a última opção (Other/Outro) e descreva.

---

## Question 1
Qual serviço executor as tarefas de exemplo do DAG devem usar?
(O pedido permite escolher; confirme a preferência.)

A) AWS Lambda — menor superfície (função + role + permissão invoke); ideal para PoC mínimo

B) AWS Glue — alinhado a ETL/data pipeline (job Glue + role); mais pesado

C) ECS Fargate — container genérico (cluster + task definition + role); mais infraestrutura

D) Other (please describe after [Answer]: tag below)

[Answer]: D (Lambda, Glue, ECS Fargate, Lake Formation + Athena e S3 como base do data lake, com Glue Data Catalog, Glue Crawler e LF-Tags para governança fine-grained de ponta a ponta, e SNS para notificação de falha/sucesso do DAG)

---

## Question 2
Como o MWAA deve obter saída à internet (obrigatório para baixar requirements e chamar APIs AWS)?

A) 1x NAT Gateway em 1 AZ + 1 subnet pública — mínimo viável e barato o suficiente para `dev` (recomendado para stack mínima)

B) 2x NAT Gateway (1 por AZ) — mais HA, ~2x custo de NAT

C) VPC Endpoints (S3 Gateway + interface endpoints) sem NAT — sem saída genérica à internet; só serviços AWS com endpoint

D) Other (please describe after [Answer]: tag below)

[Answer]: A

---

## Question 3
Onde o Terraform deve manter o state neste projeto?

A) Local (`terraform.tfstate` no workspace) — mais simples para PoC; sem backend remoto

B) S3 + DynamoDB lock — produção-like; exige bucket/tabela pré-existentes ou bootstrap

C) Other (please describe after [Answer]: tag below)

[Answer]: A

---

## Question 4
Como incluir o DAG de exemplo e o `requirements.txt`?

A) Terraform cria o bucket e pastas; DAG/requirements ficam em `dags/` no repo e são publicados com `aws s3 sync` (fora do Terraform) — alinhado ao pedido

B) Terraform também faz upload dos objetos S3 iniciais (DAG + requirements) via `aws_s3_object`

C) Other (please describe after [Answer]: tag below)

[Answer]: A

---

## Question 5
Versão do Airflow no MWAA (estável mais recente no momento do desenho)?

A) `2.10.3` — versão estável recente tipicamente disponível em MWAA (padrão proposto)

B) `2.9.2` — versão anterior estável, se a conta ainda não liberou 2.10.x

C) Other (please describe after [Answer]: tag below)

[Answer]: C (deixar airflow_version = null → MWAA usa a versão suportada mais recente; evita fixar 2.10.3/2.9.2 que pode não estar liberada na sua conta ou já estar desatualizada)

---

## Question 6
Web server access mode do MWAA?

A) `PRIVATE_ONLY` — mais seguro; acesso via VPC/VPN/bastion (recomendado)

B) `PUBLIC` — acesso via URL pública (mais simples para demo, menos seguro)

C) Other (please describe after [Answer]: tag below)

[Answer]: B (PoC de aprendizado; PRIVATE_ONLY exigiria VPN/bastion e complica o acesso à UI)

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

**O que esta extensão é.** Ativá-la aplica um conjunto de **melhores práticas direcionais de design** para construir sistemas resilientes, derivadas do **AWS Well-Architected Framework (Reliability Pillar)** e orientações de revisão de resiliência. Ela direciona requisitos, design e código para tolerância a falhas, alta disponibilidade, observabilidade e recuperabilidade — cobrindo 15 áreas de prática entre objetivos de negócio, gerenciamento de mudanças, observabilidade, alta disponibilidade, recuperação de desastres e melhoria contínua.

**O que esta extensão NÃO é.** Ativá-la **não** torna seu workload pronto para produção, nem certifica ou garante qualquer alvo de disponibilidade, RTO ou RPO. É um **ponto de partida** que estrutura boas decisões de resiliência cedo — não é um substituto para um **AWS Well-Architected Review** formal do sistema construído.

Trate a saída como um **primeiro rascunho bem fundamentado da sua postura de resiliência** para construir e validar — não um resultado final certificado para produção.

A) Sim — aplicar o baseline de resiliência como melhores práticas direcionais e orientação de design (recomendado para workloads críticos de negócio, como ponto de partida informado que você pode validar e endurecer antes do go-live)

B) Não — pular o baseline de resiliência (adequado para PoCs, protótipos e projetos experimentais onde iteração rápida importa mais do que confiabilidade)

X) Other (please describe after [Answer]: tag below)

[Answer]: B

---

## Question: Property-Based Testing Extension
As regras de testes baseados em propriedades (PBT) devem ser aplicadas neste projeto?

A) Sim — aplicar todas as regras PBT como restrições bloqueantes (recomendado para projetos com lógica de negócio, transformações de dados, serialização ou componentes com estado)

B) Parcial — aplicar regras PBT apenas para funções puras e round-trips de serialização (adequado para projetos com complexidade algorítmica limitada)

C) Não — pular todas as regras PBT (adequado para aplicações CRUD simples, projetos apenas de UI ou camadas finas de integração sem lógica de negócio significativa)

X) Other (please describe after [Answer]: tag below)

[Answer]: C
