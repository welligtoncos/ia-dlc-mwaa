# Instruções de Testes de Desempenho

**Contexto:** PoC lab — **sem SLO formal** (NFR-P-01).

## Smoke de latência (opcional)

| Check | Meta soft | Como |
|---|---|---|
| UI `/health` | < 10s | `curl` no public IP :8080 |
| Run E2E sem SELECT | minutos (aceito) | Trigger `lab_pipeline_e2e` |
| Sync DAG delay | ≤ 5 min | Timer DagSyncAgent |

## Não executar nesta fase

- Load test / stress
- Benchmarks Glue/ECS em escala
- Chaos engineering

## Critério

Documentar duração observada da run E2E no checklist do summary; não bloquear entrega por SLO.
