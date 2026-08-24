# U3 Compute Executors — Logical NFR Components

## Component Catalog

### SecurityBoundary
- **Responsibility**: Fronteira de confiança e least privilege dos executors.
- **Implements**: Roles Lambda/Glue/ECS exec+task; policies path-scoped no lake; PassRole restrito para MWAA; sem secrets no repo.
- **Collaborates with**: ServerlessRuntime, EtlRuntime, ContainerRuntime, MwaaInvokeGateway.
- **Infra mapping**: IAM resources dentro de cada module + policy aditiva no root.

### ServerlessRuntime
- **Responsibility**: Runtime Lambda (marker em `raw/dt=`).
- **Implements**: Function Python 3.12; zip via archive; memory/timeout via vars; CloudWatch log group.
- **Collaborates with**: SecurityBoundary, CostGuardrail, OperatorTooling, LakeContext (U2).
- **Infra mapping**: module `lambda_executor`.

### EtlRuntime
- **Responsibility**: Glue Job Spark passthrough raw→processed Parquet.
- **Implements**: Job Glue 4.0; G.1X × N workers (var); script no artifact bucket U1.
- **Collaborates with**: SecurityBoundary, CostGuardrail, OperatorTooling.
- **Infra mapping**: module `glue_job`.

### ContainerRuntime
- **Responsibility**: Task Fargate que escreve marker via AWS CLI.
- **Implements**: Cluster + task def; private subnets U1; SG egress; public image; smallest CPU/mem defaults.
- **Collaborates with**: SecurityBoundary, CostGuardrail, PlatformContext (U1 network).
- **Infra mapping**: module `ecs_executor`.

### CostGuardrail
- **Responsibility**: Manter perfil de custo de lab.
- **Implements**: Defaults mínimos de sizing; vars para upgrade; sem autoscaling/provisioned concurrency.
- **Config knobs**: `lambda_memory_mb`, `glue_worker_type`, `glue_number_of_workers`, `ecs_cpu`, `ecs_memory`.

### OperatorTooling
- **Responsibility**: Usabilidade operacional U3.
- **Implements**: README (CLI examples, PassRole notes); `scripts/smoke-compute.sh` com retry/backoff em APIs.
- **Out of scope U3**: alarmes SNS; orquestração DAG.
- **Infra mapping**: docs + script na Code Generation.

### MwaaInvokeGateway
- **Responsibility**: Autorizar MWAA a acionar os três executors.
- **Implements**: Policy aditiva na execution role: InvokeFunction, StartJobRun(+Get*), RunTask(+Describe/Stop), PassRole escopado.
- **Invariant**: Sem lógica de orquestração (U4).
- **Infra mapping**: `aws_iam_role_policy` no root referenciando role U1.

## Logical View

```
+------------------+     +------------------+
| OperatorTooling  |     |  CostGuardrail   |
+--------+---------+     +--------+---------+
         |                        |
         v                        v
+--------+------------------------+---------+
|           SecurityBoundary                |
+----+-------------+-------------+----------+
     |             |             |
     v             v             v
+----+-----+  +----+-----+  +----+------+
|Serverless|  |   Etl    |  |Container|
| Runtime  |  | Runtime  |  | Runtime   |
+----+-----+  +----+-----+  +----+------+
     |             |             |
     +------+------+------+------+
            |
            v
   +--------+---------+
   | MwaaInvokeGateway|
   +------------------+
```

## Implementation Notes for Infrastructure Design
1. Modules `lambda_executor`, `glue_job`, `ecs_executor` + root wiring to U1/U2 outputs.
2. Expose sizing as root variables with PoC defaults.
3. ECS: private subnets, `assign_public_ip=DISABLED`, dedicated SG.
4. Lambda: no VPC config.
5. No Interface VPC endpoints in U3 (use existing NAT).
6. Deliver `smoke-compute.sh` + README CLI examples in Code Generation.
7. MWAA policy additive only — do not replace U1 base role policy.
