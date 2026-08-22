# U1 Foundation — NFR Design Plan

**Unidade**: U1 Foundation  
**Entrada**: `nfr-requirements.md`, `tech-stack-decisions.md`  
**Saída**: `nfr-design-patterns.md`, `logical-components.md`

Preencha cada `[Answer]:` e avise (`pronto`).

---

## 1. Checklist (após aprovação)

- [x] `aidlc-docs/construction/u1-foundation/nfr-design/nfr-design-patterns.md`
- [x] `aidlc-docs/construction/u1-foundation/nfr-design/logical-components.md`
- [x] Apresentar para aprovação

---

## 2. Perguntas

### Question 1 — Padrões de resiliência (U1)

A) Fail-fast no apply + destroy manual; sem retry/circuit breaker de app (adequado a IaC PoC)

B) Documentar retries apenas para operações CLI helper (apply/sync) com backoff simples

C) Other (please describe after [Answer]: tag below)

[Answer]: B (fail-fast no apply + retries só nos helpers CLI com backoff)

### Question 2 — Padrões de escalabilidade

A) Scale-by-config: variáveis `environment_class` e flag documentada para 2º NAT (não provisionar 2º)

B) Módulo network já preparado com count/for_each para N NATs (complexidade extra agora)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (scale-by-config: variáveis + flag documentada; sem provisionar 2º NAT)

### Question 3 — Padrões de desempenho

A) Sem cache/fila; aceitar tempo de create MWAA; evitar dependências desnecessárias no grafo TF

B) Pré-criar placeholders S3/IAM em paralelo agressivo via `-target` no runbook (avançado)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (sem cache/fila; evitar dependências desnecessárias no grafo TF)

### Question 4 — Padrões de segurança

A) Defense-in-depth mínimo: BPA + SSE-S3 + least-privilege roles + deny público; secrets fora do git

B) Mesmo que A + VPC endpoints para S3 (reduz dependência de NAT para S3) nesta unidade

C) Other (please describe after [Answer]: tag below)

[Answer]: B (defense-in-depth + VPC endpoint S3)

### Question 5 — Componentes lógicos NFR a modelar

A) SecurityBaseline (BPA/SSE/tags), LoggingBaseline (CW), IdentityBoundary (roles/policies), CostGuardrail (1 NAT / small), OperatorTooling (scripts/checklist)

B) Só SecurityBaseline + IdentityBoundary (mínimo absoluto)

C) Other (please describe after [Answer]: tag below)

[Answer]: A (os cinco componentes lógicos)

---

## 3. Decisões capturadas

| # | Decisão |
|---|---|
| 1 | Fail-fast no apply + retries com backoff só nos helpers CLI |
| 2 | Scale-by-config (`environment_class` + flag 2º NAT documentada) |
| 3 | Sem cache/fila; grafo TF enxuto |
| 4 | Defense-in-depth + **VPC Gateway Endpoint S3** |
| 5 | 5 componentes lógicos: SecurityBaseline, LoggingBaseline, IdentityBoundary, CostGuardrail, OperatorTooling |

## 4. Aprovação do plano

**Status**: plano aprovado — artefatos gerados; aguardando aprovação do Design NFR U1
