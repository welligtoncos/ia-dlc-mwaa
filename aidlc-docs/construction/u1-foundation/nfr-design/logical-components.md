# U1 Foundation — Logical NFR Components

## Component Catalog

### SecurityBaseline
- **Responsibility**: Garantir controles de segurança mínimos em stores e exposição.
- **Implements**: BPA, SSE-S3 no ArtifactBucket, tags de ownership, deny público.
- **Collaborates with**: ArtifactBucket, IdentityBoundary, Network (S3 endpoint).
- **Infra mapping (next stage)**: S3 bucket encryption/public access blocks; endpoint policy baseline.

### LoggingBaseline
- **Responsibility**: Telemetria mínima do orquestrador.
- **Implements**: MWAA → CloudWatch Logs (scheduler/webserver/worker/DAG processing).
- **Collaborates with**: AirflowEnvironment.
- **Out of scope U1**: Alarmes SNS.

### IdentityBoundary
- **Responsibility**: Fronteira de confiança least privilege.
- **Implements**: MWAA execution role (base S3 artifacts + logs); `policies/terraform-apply-policy.json` (U1–U4); checklist IAM.
- **Invariant**: Sem `Action="*"` / AdministratorAccess.

### CostGuardrail
- **Responsibility**: Manter perfil de custo de lab.
- **Implements**: `mw1.small`, 1 NAT; documentação de headroom (medium / 2 NAT) sem provisionar.
- **Config knobs**: `environment_class`, docs `enable_second_nat`.

### OperatorTooling
- **Responsibility**: Usabilidade operacional.
- **Implements**: README (init/plan/apply/destroy), `scripts/apply.sh` (retry/backoff), `scripts/sync-dags.sh` (retry/backoff), IAM review checklist.
- **Note**: Sync script existe desde U1 (bucket pronto); conteúdo DAG completo em U4.

### S3PrivatePath (network security adjunct)
- **Responsibility**: Acesso S3 sem hairpin pelo NAT quando possível.
- **Implements**: VPC Gateway Endpoint S3 associado às route tables privadas (e pública se necessário para consistência).
- **Collaborates with**: NetworkCapability, SecurityBaseline, ArtifactBucket.

## Logical View

```
+------------------+     +------------------+
| OperatorTooling  |     |  CostGuardrail   |
+--------+---------+     +--------+---------+
         |                        |
         v                        v
+--------+------------------------+---------+
|           IdentityBoundary                |
+--------+------------------------+---------+
         |
         v
+--------+---------+     +------------------+
| SecurityBaseline +-----| S3PrivatePath    |
+--------+---------+     +--------+---------+
         |                        |
         v                        v
+--------+---------+     +--------+---------+
| LoggingBaseline  |     | Artifact/Network |
+------------------+     +------------------+
```

## Implementation Notes for Infrastructure Design
1. Modelar S3 Gateway Endpoint no módulo `network` (ou sub-recurso).
2. Encryption SSE-S3 no módulo `artifact_store`.
3. Vars: `environment_class`, (doc-only) second NAT.
4. Não criar alarmes SNS em U1.
5. Entregar scripts + checklist + apply-policy na Code Generation.
