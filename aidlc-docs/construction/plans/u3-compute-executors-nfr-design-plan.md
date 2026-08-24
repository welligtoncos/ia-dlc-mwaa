# U3 Compute Executors — NFR Design Plan

**Unidade**: U3  
**Entrada**: `nfr-requirements.md`, `tech-stack-decisions.md`, functional-design U3  
**Saída**: `nfr-design-patterns.md`, `logical-components.md`

Preencha cada `[Answer]:` e avise (`pronto`).

---

## 1. Checklist (após aprovação)

- [x] `nfr-design-patterns.md`
- [x] `logical-components.md`
- [x] Apresentar para aprovação

---

## 2. Perguntas

### Question 1 — Padrões de resiliência

A) Fail-fast no apply TF e nas invocações; smoke script com retry/backoff só em falhas transitórias de API; sem DLQ/SQS; Glue/Lambda/ECS sem retry policy agressiva no recurso (recomendado)

B) DLQ na Lambda + Glue job bookmark + ECS redeploy automático

C) Other (please describe after [Answer]: tag below)

[Answer]: A (fail-fast; retry só em falha transitória de API no smoke; sem DLQ/bookmark/redeploy)

### Question 2 — Padrões de escalabilidade

A) Scale-by-config: vars `lambda_memory_mb`, `glue_worker_type`, `glue_number_of_workers`, `ecs_cpu`, `ecs_memory`; defaults PoC; headroom só documentado

B) Autoscaling ECS service + provisioned concurrency Lambda já em U3

C) Other (please describe after [Answer]: tag below)

[Answer]: A (scale-by-config com vars de sizing; headroom documentado)

### Question 3 — Padrões de desempenho

A) Sem cache/fila; timeouts explícitos (Lambda 60s; Glue/ECS conforme PoC); Glue worker mínimo; Fargate smallest; particionamento `dt=` herdado do lake U2

B) Pré-aquecer Lambda (scheduled ping) + Glue flex execution já agora

C) Other (please describe after [Answer]: tag below)

[Answer]: A (sem cache/fila; timeouts explícitos; Glue/Fargate mínimos; dt= herdado de U2)

### Question 4 — Padrões de segurança

A) Defense-in-depth: roles dedicadas; resource ARNs escopados; ECS em private subnets + SG egress-only; Lambda fora VPC; PassRole MWAA restrito; sem secrets no código

B) Mesmo que A + VPC endpoints Interface (ECR/Logs/STS) para reduzir NAT nas tasks ECS

C) Other (please describe after [Answer]: tag below)

[Answer]: A (defense-in-depth sem interface endpoints)

### Question 5 — Componentes lógicos NFR a modelar

A) SecurityBoundary, ServerlessRuntime, EtlRuntime, ContainerRuntime, CostGuardrail (sizing vars), OperatorTooling (README + smoke-compute.sh), MwaaInvokeGateway (policy aditiva)

B) Só SecurityBoundary + três Runtimes (mínimo)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (os sete componentes lógicos)

---

## 3. Decisões capturadas

| # | Decisão |
|---|---|
| 1 | Fail-fast; retry só no smoke para erros transitórios |
| 2 | Scale-by-config (vars sizing); sem autoscaling |
| 3 | Timeouts explícitos; sizing mínimo; `dt=` do lake |
| 4 | Defense-in-depth; sem VPC interface endpoints |
| 5 | 7 componentes lógicos NFR |

## 4. Aprovação do plano

**Status**: respostas aceitas — artefatos gerados; aguardando aprovação do Design NFR U3
