# U1-orchestrator-ec2 — Logical NFR Components

## Component Catalog

### SecurityBaseline
- **Responsibility**: Controles mínimos no host orquestrador e artefatos.
- **Implements**: IMDSv2 required; SG ingress 8080/`operator_cidr`; SSE-S3 bucket; tags incl. `CostCenter=lab`.
- **Collaborates with**: AirflowHost, S3PrivatePath, IdentityBoundary.
- **Infra mapping**: `aws_instance` metadata_options; SG rules; reuse artifact_store encryption.

### BootstrapAgent
- **Responsibility**: First-boot e recovery do stack Compose.
- **Implements**: user_data pull `airflow-ec2/` from S3; docker pre-pull (digest pin); compose up with retries; systemd `Restart=on-failure`; generate UI password → SSM Parameter.
- **Collaborates with**: ComposePackage (S3), ExecutionIdentity (instance role), SecurityBaseline.
- **Infra mapping**: user_data template; `aws_ssm_parameter`; S3 objects upload on apply.

### DagSyncAgent
- **Responsibility**: Manter DAGs locais alinhados ao bucket.
- **Implements**: systemd timer/cron every **5 min** — `aws s3 sync` `dags/` → local mount.
- **Collaborates with**: ArtifactStore, AirflowHost, S3PrivatePath.
- **Infra mapping**: embedded in bootstrap script / unit files (not separate TF module).

### CostGuardrail
- **Responsibility**: Custo previsível de lab.
- **Implements**: `t3.medium` default; scripts start/stop; README ~US$ 1–2/day; budget alert suggested (out of TF); no EIP.
- **Config knobs**: `airflow_instance_type`; documented headroom only.
- **Collaborates with**: OperatorTooling.

### OperatorTooling
- **Responsibility**: UX do operador para EC2 Airflow.
- **Implements**: `airflow-ec2-start.sh`, `airflow-ec2-stop.sh`, `airflow-ec2-status.sh` (SSM + curl UI); README (IP dinâmico, senha via SSM); IAM checklist.
- **Collaborates with**: BootstrapAgent, HealthMonitor.

### HealthMonitor
- **Responsibility**: Detecção básica de falha da instância.
- **Implements**: CloudWatch alarm on EC2 status check failed; **no SNS** until U4.
- **Collaborates with**: AirflowHost.
- **Infra mapping**: `aws_cloudwatch_metric_alarm`.

### S3PrivatePath (reuse U1)
- **Responsibility**: Tráfego S3 sem NAT hairpin.
- **Implements**: Existing VPC Gateway Endpoint S3 on route tables.
- **Collaborates with**: BootstrapAgent, DagSyncAgent, ArtifactStore.

### IdentityBoundary (EC2 mode)
- **Responsibility**: Least privilege for orchestrator principal.
- **Implements**: Role `…-airflow-ec2-execution` + instance profile; SSM core; lake/compute policies (U2/U3 wiring); **no MWAA role** when mode=ec2.
- **Invariant**: No `Action="*"`; no access keys on instance.

## Logical View

```
+------------------+     +------------------+
| OperatorTooling  |     |  CostGuardrail   |
+--------+---------+     +--------+---------+
         |                        |
         v                        v
+--------+------------------------+---------+
|           IdentityBoundary (EC2)          |
+--------+------------------------+---------+
         |
    +----+----+----------+----------+
    v         v          v          v
Security  Bootstrap  DagSync   HealthMonitor
Baseline   Agent      Agent
    |         |          |
    +----+----+----------+
         v
   S3PrivatePath ──► ArtifactStore
         |
         v
     AirflowHost (EC2 + Compose)
```

## Implementation Notes for Infrastructure Design
1. New module `airflow_ec2`: instance, SG, alarm, SSM param placeholder, S3 compose upload.
2. Root: `orchestrator_mode` conditional; skip `module.mwaa` + MWAA IAM when `ec2`.
3. Identity: new EC2 role + attach existing lake/compute policy documents to EC2 principal.
4. Network: reuse public subnet + existing S3 gateway endpoint; new SG for Airflow EC2.
5. Bootstrap: templates in module `files/` or `templates/`; upload to S3 on apply (Q3 app design).
6. No CloudWatch agent (journald only); no SSM VPC interface endpoint.
7. Tag `CostCenter=lab` on EC2-related resources.

## Mode Switch
| `orchestrator_mode` | Active logical stack |
|---|---|
| `ec2` (default) | Components above |
| `mwaa` | Legacy U1 LoggingBaseline + OrchestratorMWAA (unchanged path) |
